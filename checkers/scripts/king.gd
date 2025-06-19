extends Man

class_name King

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func available_captures(board):
	var avail_captures = super.available_captures(board)
	var backward = 1 if self.white else -1
	var move = Vector2i(self.x + backward * 2, self.y + 2)
	if _check_capture(move, board):
		avail_captures.push_back(move)
	move.y = self.y - 2
	if _check_capture(move, board):
		avail_captures.push_back(move)
	return avail_captures
	
func available_moves(board):
	var avail_moves = super.available_moves(board)
	var backward = 1 if self.white else -1
	var move = Vector2i(self.x + backward, self.y + 1)
	if _check_move(move, board):
		avail_moves.push_back(move)
	move.y = self.y - 1
	if _check_move(move, board):
		avail_moves.push_back(move)
	return avail_moves
