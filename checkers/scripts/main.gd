extends Control

signal game_finished

const DEFAULT_VOLUME = -10

var logic: GameLogic
var retry_button
var quit_button
var tween
var players_ready : Dictionary
var is_ready

@onready var gui = $VBoxContainer/Board/Grid
@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var menu_scene = $Menu
@onready var my_multiplayer = $MultiPlayer


func _ready():
	self.is_ready = false
	
	$MenuTheme.volume_db = DEFAULT_VOLUME
	self.retry_button = $Menu/VBoxContainer/HboxContainer/PlayAgain
	self.quit_button = $Menu/VBoxContainer/HboxContainer/Quit

	my_multiplayer.connection()
	
	
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))
	my_multiplayer.all_peers_connected.connect(func(): 
		retry_button.connect("pressed", Callable(self, "_on_play_again_pressed"))
		_game_setup()
	)
	

func _game_setup():
	print("alllber")
	self.player1.inizialize("Plants", 12, true, false)
	self.player1.set_time_left(60)
	$VBoxContainer/BotHUD/Player1.text = self.player1.get_ign()
	$VBoxContainer/BotHUD/Player1Timer.text = self.player1.format_time()

	self.player2.inizialize("Zombies", 12, false, false)
	self.player2.set_time_left(60)
	$VBoxContainer/TopHUD/Player2.text = self.player2.get_ign()
	$VBoxContainer/TopHUD/Player2Timer.text = self.player2.format_time()

	self.logic = GameLogic.new()
	self.logic.set_multiplayer(self.my_multiplayer)
	self.logic.set_players(player1, player2)
	self.player1.connect_to_target(self.logic)
	self.player2.connect_to_target(self.logic)
	self.logic.setup_matrix()
	self.logic.connect_to_target(self.gui)
	self.logic.set_grid(self.gui)
	self.gui.set_appearence_only(true)
	self.gui.connect_to_target(self.logic)
	self.gui.setup_gui(self.logic.get_board())

	self._fade_in_music()
	self._menu_animation()


func _menu_animation():
	self.menu_scene.visible = true
	self.tween = create_tween()
	self.tween.set_parallel(true)
	self.tween.tween_property($VBoxContainer, "modulate", Color(0.1, 0.1, 0.1, 0.9), 2)
	self.tween.tween_property(self.menu_scene, "modulate", Color(1, 1, 1, 0.9), 2)


func _play_animation():
	self.tween.kill()
	self.tween = create_tween()
	self.tween.set_parallel(true)
	self.tween.tween_property($VBoxContainer, "modulate", Color(1, 1, 1, 1), 1)
	self.tween.tween_property(self.menu_scene, "modulate", Color(1, 1, 1, 0), 0.5)
	self.tween.connect("finished", func(): self.menu_scene.visible = false)


func _play(restart = false):
	self.gui.set_appearence_only(false)

	self._fade_out_music()
	self._play_animation()

	self.logic.game_start(self.game_finished)
	await self.game_finished
	self.player1.stop_timer()
	self.player2.stop_timer()
	var winner = self.logic.get_winner()
	var winnertext: String
	match winner:
		1:
			winnertext = player1.get_ign() + " won!"
			$Win.play()
		2:
			winnertext = player2.get_ign() + " won!"
			$Win.play()
		_:
			winnertext = "Draw"
			$Draw.play()

	self.quit_button.disabled = false
	self.retry_button.disabled = false
	
	$Menu/VBoxContainer/WinnerText.text = winnertext

	self.gui.set_appearence_only(true)
	self._fade_in_music()
	self._menu_animation()


func _fade_out_music():
	if $MenuTheme.playing:
		var t = create_tween()
		t.tween_property($MenuTheme, "volume_db", -80, 8)
		await t.finished
		$MenuTheme.stop()
		$MenuTheme.volume_db = DEFAULT_VOLUME


func _fade_in_music():
	if not $MenuTheme.playing:
		$MenuTheme.volume_db = -80
		$MenuTheme.play()
		var t = create_tween()
		t.tween_property($MenuTheme, "volume_db", DEFAULT_VOLUME, 0.5)


func _on_player_1_update_label() -> void:
	$VBoxContainer/BotHUD/Player1Timer.text = self.player1.format_time()


func _on_player_2_update_label() -> void:
	$VBoxContainer/TopHUD/Player2Timer.text = self.player2.format_time()

func _on_play_again_pressed() -> void:
	
	self.is_ready = true
	
	self.retry_button.disabled = true
	self.quit_button.disabled = true
	
	# Notifica gli altri peer che questo giocatore è pronto
	var my_id = my_multiplayer.multiplayer.get_unique_id()
	_set_player_ready.rpc(my_id)
	_set_player_ready(my_id)  # Imposta anche localmente
	
	#_update_button_text()
	
	if retry_button.text == "Play again":
		var board_path = $VBoxContainer/Board.scene_file_path
		$VBoxContainer/Board.queue_free()
		self.gui.queue_free()

		await get_tree().process_frame
		var new_board = load(board_path).instantiate()
		new_board.name = "Board"

		$VBoxContainer.add_child(new_board)
		$VBoxContainer.move_child(new_board, 1)
		self.gui = $VBoxContainer.get_node("Board/Grid")

		self._game_setup()
	
	self.retry_button.text = "Waiting for client"
			
	

# Funzione RPC per sincronizzare lo stato "ready" tra i peer
@rpc("any_peer", "reliable")
func _set_player_ready(peer_id: int) -> void:
	self.players_ready[peer_id] = true
	print("Giocatore %d è pronto. Giocatori pronti: %s" % [peer_id, str(players_ready)])
	
	_check_all_ready()

func _check_all_ready() -> void:
	var connected_peers = my_multiplayer.multiplayer.get_peers()
	var my_id = my_multiplayer.multiplayer.get_unique_id()
	var total_players = connected_peers.size() + 1  # +1 per il giocatore locale
	
	print("Controllo ready: %d/%d giocatori pronti" % [players_ready.size(), total_players])
	
	if players_ready.size() >= total_players:
		# Tutti i giocatori sono pronti, inizia il gioco
		self._play()

func _on_quit_pressed() -> void:
	get_tree().quit()
