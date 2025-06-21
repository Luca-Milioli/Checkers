extends Control

@onready var gui = $VBoxContainer/Board/Grid
@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var menu_scene = $Menu

var logic : GameLogic
var retry_button
var quit_button
var tween

# TODO
# 1: LA PRIORITà DI CATTURA SI DEVE METTERE ANCHE AL DAMONE
# 2: SE UN PLAYER è BLOCCATO HA VINTO L'ALTRO (SE NON SONO ENTRAMBI BLOCCATI)
# 3: WIN PER TEMPO
# 4: RIPETIZIONE
# 6: QUANDO SI PROMUOVE NON PUOI CONTINUARE UNA CATTURA MULTIPLA IN QUEL TURNO

func _ready():
	
	self.retry_button = get_node("Menu/VBoxContainer/HboxContainer/PlayAgain")
	self.quit_button = get_node("Menu/VBoxContainer/HboxContainer/Quit")
	
	retry_button.connect("pressed", Callable(self, "_on_play_again_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))
	
	_game_setup()
	
func _game_setup():
	self.player1.inizialize("Peashooter", 12, true, false)
	self.player1.set_time_left(600)
	$VBoxContainer/BotHUD/Player1.text = self.player1.get_ign()
	$VBoxContainer/BotHUD/Player1Timer.text = self.player1.format_time()
	
	self.player2.inizialize("Zombie", 12, false, false)
	self.player2.set_time_left(600)
	$VBoxContainer/TopHUD/Player2.text = self.player2.get_ign()
	$VBoxContainer/TopHUD/Player2Timer.text = self.player2.format_time()
	
	self.logic  = GameLogic.new()
	self.logic.set_players(player1, player2)
	self.logic.setup_matrix()
	self.logic.connect_to_target(self.gui)
	self.logic.set_grid(self.gui)
	self.gui.set_appearence_only(true)
	self.gui.connect_to_target(self.logic)
	self.gui.setup_gui(self.logic.get_board())
	
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
	self.tween.tween_property($VBoxContainer, "modulate", Color(1, 1, 1, 1), 1.7)
	self.tween.tween_property(self.menu_scene, "modulate", Color(1, 1, 1, 0), 0.5)
	self.tween.connect("finished", func(): self.menu_scene.visible = false)

func _play(restart = false):
	self.gui.set_appearence_only(false)
	self._play_animation()
	var winner = await self.logic.game_start()
	
	var winnertext: String
	match winner:
		1:
			winnertext = player1.get_ign() + " won!"
		2:
			winnertext = player2.get_ign() + " won!"
		_:
			winnertext = "Draw"
	
	self.quit_button.disabled = false
	self.retry_button.disabled = false
	self.retry_button.text = "Play again"
	$Menu/VBoxContainer/WinnerText.text = winnertext
	
	self._menu_animation()
	
func _on_player_1_update_label() -> void:
	$VBoxContainer/BotHUD/Player1Timer.text = self.player1.format_time()

func _on_player_2_update_label() -> void:
	$VBoxContainer/TopHUD/Player2Timer.text = self.player2.format_time()

func _on_play_again_pressed() -> void:
	self.retry_button.disabled = true
	self.quit_button.disabled = true
	
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
		
	self._play()

func _on_quit_pressed() -> void:
	get_tree().quit()
