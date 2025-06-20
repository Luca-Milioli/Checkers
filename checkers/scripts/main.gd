extends Control

@onready var gui = $VBoxContainer/Board/Grid
@onready var player1 = $Player1
@onready var player2 = $Player2

var logic : GameLogic

func _ready():
	self.player1.inizialize("Luca", 12, true, false)
	self.player1.set_time_left(600)
	self.player2.inizialize("Federico", 12, false, false)
	self.player2.set_time_left(600)
	
	self.logic  = GameLogic.new()
	self.logic.set_players(player1, player2)
	self.logic.setup_matrix()
	self.logic.connect_to_target(self.gui)
	self.gui.connect_to_target(self.logic)
	self.gui.setup_gui(self.logic.get_board())
	self.logic.set_grid(self.gui)
	self.logic.game_start()


func _on_player_1_update_label() -> void:
	$VBoxContainer/BotHUD/Player1Timer.text = self.player1.format_time()

func _on_player_2_update_label() -> void:
	$VBoxContainer/TopHUD/Player2Timer.text = self.player2.format_time()
