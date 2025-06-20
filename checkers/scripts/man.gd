extends TextureRect

class_name Man

enum {PLAYER_MAN, IA_MAN, NO_MAN}

var white
var coordinates : Vector2i
var _is_selected : bool
const DEFAULT_MODULATE = Color(1,1,1,1)
const CLICK_MODULATE = Color(0.4, 1, 0.8, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._is_selected = false

func set_white(white: bool):
	self.white = white

func set_image(path: String):
	self.texture = load(path)

func set_coordinates(x: int, y: int) -> void:
	self.coordinates[0] = x
	self.coordinates[1] = y
	
func get_coordinates() -> Vector2i:
	return self.coordinates

func select():
	self.modulate = self.CLICK_MODULATE
	self._is_selected = true

func deselect():
	self.modulate = self.DEFAULT_MODULATE
	self._is_selected = false

func is_selected():
	return self.is_selected

func is_white():
	return self.white
	
func _check_capture(move, board) -> bool:
	if not _check_move(move, board):
		return false
	
	var coord = self.get_coordinates()
	var captured_x = coord[0] - 1 if self.white else coord[0] + 1
	var captured_y = coord[1] - 1 if coord[1] - 2 == move.y else coord[1] + 1
	var captured = board[captured_x][captured_y]
	if captured == IA_MAN and self.white or captured == PLAYER_MAN and not self.white:
		return true
	return false

func available_captures(board) -> Array:
	var direction = -1 if self.white else 1
	var avail_captures = []
	var coord = self.get_coordinates()
	var move = Vector2i(coord[0] + direction * 2, coord[1] + 2)
	if _check_capture(move, board):
		avail_captures.push_back(move)
	move.y = coord[1] - 2
	if _check_capture(move, board):
		avail_captures.push_back(move)
	return avail_captures

func _check_move(move, board) -> bool:
	if move.x < 0 or move.x >= 8 or move.y < 0 or move.y >= 8:		#out of board
		return false
	var cell = board[move.x][move.y]
	if cell != NO_MAN:		# can't go on an occupied cell
		return false
	return true

func available_moves(board) -> Array:
	var direction = -1 if self.white else 1
	var avail_moves = []
	var coord = self.get_coordinates()
	var move = Vector2i(coord[0] + direction, coord[1] + 1)
	if _check_move(move, board):
		avail_moves.push_back(move)
	move.y = coord[1] - 1
	if _check_move(move, board):
		avail_moves.push_back(move)
	return avail_moves
