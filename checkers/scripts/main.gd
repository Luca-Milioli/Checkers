extends Control

@onready var gui = $VBoxContainer/Board/Grid
@onready var player1 = $Player1
@onready var player2 = $Player2

@onready var menu_scene = $WinnerControl

var logic : GameLogic

func _ready():
	var retry_button = get_node("WinnerControl/VBoxContainer/HboxContainer/PlayAgain")
	var quit_button = get_node("WinnerControl/VBoxContainer/HboxContainer/Quit")
	
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

func _play():
	self.gui.set_appearence_only(false)
	self.menu_scene.visible = false
	var winner = await self.logic.game_start()
	var winnertext = player1.get_ign() if winner == 1 else player2.get_ign()
	$WinnerControl/VBoxContainer/WinnerText.text = winnertext
	
func _on_player_1_update_label() -> void:
	$VBoxContainer/BotHUD/Player1Timer.text = self.player1.format_time()

func _on_player_2_update_label() -> void:
	$VBoxContainer/TopHUD/Player2Timer.text = self.player2.format_time()

func _on_play_again_pressed() -> void:
	self.menu_scene.visible = false
	self._play()

func _on_quit_pressed() -> void:
	print("quit")
