extends Node

var logic : GameLogic
@onready var gui = $Board/Grid

func _ready():
	self.logic = GameLogic.new()
	self.logic.connect_to_target(self.gui)
	self.logic.setup_matrix()
	#self.logic.print_board()
	self.logic.game_start()
