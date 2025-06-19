extends Control

@onready var gui = $VBoxContainer/Board/Grid
#@onready var label_updater = $UpdateLabel
@onready var player1 = $Player1
@onready var player2 = $Player2

func _ready():
	self.player1.inizialize("Luca", 12, true, false)
	self.player1.set_time_left(600)
	self.player2.inizialize("Federico", 12, false, false)
	self.player2.set_time_left(600)
	
	var logic = GameLogic.new()
	logic.set_players(player1, player2)
	logic.setup_matrix()
	logic.connect_to_target(self.gui)
	gui.connect_to_target(logic)
	
	#self.logic.print_board()
	self.gui.setup_gui(logic.get_board())
	logic.set_grid(self.gui)
	logic.game_start()


func _on_player_1_update_label() -> void:
	$VBoxContainer/BotHUD/Player1Timer.text = self.player1.format_time()

func _on_player_2_update_label() -> void:
	$VBoxContainer/TotHUD/Player1Timer.text = self.player2.format_time()
