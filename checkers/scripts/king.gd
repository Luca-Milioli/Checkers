extends Man

class_name King

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func inherit_from_man(man: Man):
	self.expand_mode = man.expand_mode
	self.stretch_mode = man.stretch_mode
	self.custom_minimum_size = man.custom_minimum_size
	self.layout_direction = man.layout_direction
	self.anchor_left = man.anchor_left
	self.anchor_right = man.anchor_right
	self.anchor_top = man.anchor_top
	self.anchor_bottom = man.anchor_bottom
	self.size = man.size
	self.position = man.position
	self.scale = man.scale
	var coord = man.get_coordinates()
	self.set_coordinates(coord.x, coord.y)
	self.set_white(man.is_white())
	self.modulate = man.modulate
	self.visible = true

func _check_capture(move, board) -> bool:
	if not super._check_move(move, board):
		return false
	var captured_x = self.coordinates.x - 1 if self.coordinates.x - 2 == move.x else self.coordinates.x + 1
	var captured_y = self.coordinates.y - 1 if self.coordinates.y - 2 == move.y else self.coordinates.y + 1
	var captured = board[captured_x][captured_y]
	if captured >= BLACK_MAN and self.white or captured <= WHITE_KING and not self.white:
		return true
	return false

func available_captures(board):
	var avail_captures = super.available_captures(board)
	var backward = 1 if self.white else -1
	var coord = self.get_coordinates()
	var move = Vector2i(coord.x + backward * 2, coord.y + 2)
	if _check_capture(move, board):
		avail_captures.push_back(move)
	move.y = coord.y - 2
	if _check_capture(move, board):
		avail_captures.push_back(move)
	return avail_captures
	
func available_moves(board):
	var avail_moves = super.available_moves(board)
	var backward = 1 if self.white else -1
	var coord = self.get_coordinates()
	var move = Vector2i(coord.x + backward, coord.y + 1)
	if super._check_move(move, board):
		avail_moves.push_back(move)
	move.y = coord.y - 1
	if super._check_move(move, board):
		avail_moves.push_back(move)
	return avail_moves
