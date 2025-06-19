extends Control

var logic : GameLogic
@onready var gui = $VBoxContainer/Board/Grid
func _ready():
	self.logic = GameLogic.new()
	self.logic.connect_to_target(self.gui)
	self.gui.connect_to_target(self.logic)
	self.logic.setup_matrix()
	self.gui.setup_gui(logic.get_board())
	self.logic.set_grid(self.gui)
	self.logic.game_start()
