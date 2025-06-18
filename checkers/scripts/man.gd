extends TextureRect

class_name Man

enum {PLAYER_MAN, IA_MAN, NO_MAN}

var white
var x
var y
var _is_selected : bool
const DEFAULT_MODULATE = Color(1,1,1,1)
const CLICK_MODULATE = Color(0.4, 1, 0.8, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._is_selected = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_image(white = true):
	var path = "res://art/white_man.jpg" if white else "res://art/black_man.jpg"
	self.white = white
	self.texture = load(path)

func set_coordinates(x: int, y: int) -> void:
	self.x = x
	self.y = y
	
func get_coordinates():
	return Vector2i(self.x, self.y)

func select():
	self.modulate = self.CLICK_MODULATE
	self._is_selected = true

func deselect():
	self.modulate = self.DEFAULT_MODULATE
	self._is_selected = false

func is_selected():
	return is_selected

func is_white():
	return self.white
	
func _check_capture(move, board):
	if not _check_move(move, board):
		return false
	var captured_x = self.x - 1 if self.x - 2 == move.x else self.x + 1
	var captured_y = self.x - 1 if self.white else self.x + 1
	var captured = board[captured_x][captured_y]
	if captured == IA_MAN and self.white or captured == PLAYER_MAN and not self.white:
		return true
	return false

func _check_move(move, board):
	if move.x < 0 or move.x >= 8 or move.y < 0 or move.y >= 8:		#out of board
		return false 
	var cell = board[move.x][move.y]
	if cell != NO_MAN:		# can't go on an occupied cell
		return false

func available_moves(board):
	var direction = -1 if self.white else 1
	var avail_moves = []
	var move = Vector2i(self.x + 2, self.y + direction * 2)
	if _check_capture(move, board):
		avail_moves.push_back(move)
	move.x = self.x - 2
	if _check_capture(move, board):
		avail_moves.push_back(move)
	if not avail_moves.is_empty():		#if there's a capture, it's mandatory capturing
		return avail_moves
	move = Vector2i(self.x + 1, self.y + direction)
	if _check_move(move, board):
		avail_moves.push_back(move)
	move.x = self.x - 1
	if _check_move(move, board):
		avail_moves.push_back(move)
	return avail_moves
