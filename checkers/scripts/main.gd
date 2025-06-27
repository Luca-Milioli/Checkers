extends Control

signal game_finished
signal connection_done

const DEFAULT_VOLUME = -10

var logic: GameLogic
var retry_button
var quit_button
var tween
var players_ready : Dictionary
var is_server_white: bool

@onready var gui = $VBoxContainer/BoardWrapper/Board/Grid
@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var menu_scene = $Menu
@onready var my_multiplayer = $Multiplayer


func _ready():
	$TransitionCircle/Transition.play("fade_in")
	await $TransitionCircle/Transition.animation_finished
	$MenuTheme.volume_db = DEFAULT_VOLUME
	self.retry_button = $Menu/VBoxContainer/HboxContainer/PlayAgain
	self.quit_button = $Menu/VBoxContainer/HboxContainer/Quit
	_fade_in_music()
	_menu_animation()
	self.retry_button.text = "Connect"
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))
	retry_button.connect("pressed", Callable(self, "_on_play_again_pressed"))
	
func _multi_setup():
	self.my_multiplayer.connection()
	self.my_multiplayer.all_peers_connected.connect(func():
		_main_menu_out_animation()
		_game_setup()
	)
	
func _game_setup():
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
	self.gui.set_multiplayer(self.my_multiplayer)
	
	$VBoxContainer/TopHUD.visible = true
	$VBoxContainer/BotHUD.visible = true
	#self._fade_in_music()
	self._menu_animation()

func _main_menu_out_animation():
	self.tween = create_tween()
	self.tween.tween_property($Scroller, "modulate", Color(1, 1, 1, 0), 1.5)
	self.tween.connect("finished", func(): $Scroller.visible = false)
	
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

func _assign_colors(is_server_white: bool):
	var my_id = self.my_multiplayer.multiplayer.get_unique_id()
	var client_id = self.my_multiplayer.multiplayer.get_peers()[0] if self.my_multiplayer.multiplayer.is_server() else my_id
	if is_server_white:
		self.player1.set_peer_id(1)
		self.player2.set_peer_id(client_id)
	else:
		self.player1.set_peer_id(client_id)
		self.player2.set_peer_id(1)
	if my_id == self.player2.get_peer_id():
		_flip_gui()
	_play()

func _flip_gui():
	$VBoxContainer/BoardWrapper.scale = Vector2(1, -1)
	$VBoxContainer/BoardWrapper.position.y += $VBoxContainer/BoardWrapper.size.y
	
	self.gui.flip()
	
	var tmp = $VBoxContainer/BotHUD/Player1.text
	$VBoxContainer/BotHUD/Player1.text = $VBoxContainer/TopHUD/Player2.text
	$VBoxContainer/TopHUD/Player2.text = tmp
	
	var timer1 = self.player1.get_child(0)
	self.player1.remove_child(timer1)
	var timer2 = self.player2.get_child(0)
	self.player2.remove_child(timer2)
	self.player1.add_child(timer2)
	self.player2.add_child(timer1)

@rpc("authority")
func _receive_white_assignment(is_server_white: bool):
	_assign_colors(is_server_white)


func _setup_players():
	self.player1.inizialize("Plants", 12, false, false)
	self.player1.set_time_left(60)
	$VBoxContainer/BotHUD/Player1.text = self.player1.get_ign()
	$VBoxContainer/BotHUD/Player1Timer.text = self.player1.format_time()
	
	self.player2.inizialize("Zombies", 12, false, false)
	self.player2.set_time_left(60)
	$VBoxContainer/TopHUD/Player2.text = self.player2.get_ign()
	$VBoxContainer/TopHUD/Player2Timer.text = self.player2.format_time()
	
	if my_multiplayer.multiplayer.get_unique_id() == 1:
		self.is_server_white = randi() % 2 == 0  # true → server è bianco
		rpc_id(my_multiplayer.multiplayer.get_peers()[0], "_receive_white_assignment", self.is_server_white)  # invia al client
		_assign_colors(self.is_server_white)

func _play(restart = false):
	self.logic.set_players(player1, player2)

	self.gui.set_appearence_only(false)

	self._fade_out_music()
	self._play_animation()

	self.logic.game_start(self.game_finished)
	await self.game_finished
	self.player1.stop_timer()
	self.player2.stop_timer()
	var winner = self.logic.get_winner()
	end_game(winner)

func end_game(winner):
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
	self.retry_button.text = "Play again"
	
	for player in players_ready:
		players_ready[player] = false
		
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
	if self.retry_button.text == "Connect":
		self.retry_button.text = "Connecting..."
		self.retry_button.disabled = true
		_multi_setup()
		return
		
	self.retry_button.disabled = true
	self.quit_button.disabled = true
	
	if self.retry_button.text == "Play again":
		var board_path = $VBoxContainer/BoardWrapper/Board.scene_file_path
		$VBoxContainer/BoardWrapper/Board.queue_free()
		self.gui.queue_free()

		await get_tree().process_frame
		var new_board = load(board_path).instantiate()
		new_board.name = "Board"

		$VBoxContainer.add_child(new_board)
		$VBoxContainer.move_child(new_board, 1)
		self.gui = $VBoxContainer.get_node("Board/Grid")
		
		self.retry_button.text = "start game"
		#await self._multi_setup()
		self._game_setup()
		#self._on_play_again_pressed()
	
	self.retry_button.text = "Waiting for client..."
	
	# Notifica gli altri peer che questo giocatore è pronto
	var my_id = my_multiplayer.multiplayer.get_unique_id()
	_set_player_ready.rpc(my_id)
	_set_player_ready(my_id)  # Imposta anche localmente
	

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
		self.players_ready = {} # reset for next game
		# Tutti i giocatori sono pronti, inizia il gioco
		_setup_players()

func _on_quit_pressed() -> void:
	if self.quit_button.text == "Main menu":
		$TransitionCircle.visible = true
		$TransitionCircle/Transition.play("fade_out")
		await $TransitionCircle/Transition.animation_finished
		get_tree().reload_current_scene()
	else:
		$TransitionCircle/Transition.play("fade_out")
		await $TransitionCircle/Transition.animation_finished
		get_tree().quit()


func _on_multiplayer_all_peers_connected() -> void:
	self.retry_button.text = "Start game"
	self.retry_button.disabled = false


func _on_multiplayer_peer_disconnected_signal(id: Variant) -> void:
	var winnerid = self.my_multiplayer.multiplayer.get_unique_id()
	var winner : int
	if self.player1.get_peer_id() == 0:
		winner = 0
	elif self.player1.get_peer_id() == winnerid:
		if self.player1.is_white():
			winner = 1
		else:
			winner = 2
	else:
		if self.player2.is_white():
			winner = 2
		else:
			winner = 1
	end_game(winner)
	self.retry_button.disabled = true
	self.quit_button.text = "Main menu"
