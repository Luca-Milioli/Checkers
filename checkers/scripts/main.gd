extends Node

var logic : GameLogic

func _ready():
	self.logic = GameLogic.new()
	self.logic.setup_matrix()
	self.logic.print_board()
	self.logic.game_start()
