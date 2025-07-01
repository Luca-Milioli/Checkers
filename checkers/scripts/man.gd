extends TextureRect

class_name Man

enum { WHITE_MAN, WHITE_KING, NO_MAN, BLACK_MAN, BLACK_KING }

const SIZE = 8
const DEFAULT_MODULATE = Color(1, 1, 1, 1)
const CLICK_MODULATE = Color(0.4, 1, 0.8, 1)

var white: bool
var coordinates: Vector2i
var _is_selected: bool


func set_white(white):
	self.white = white


func set_image(path: String):
	self.texture = load(path)


func set_coordinates(x: int, y: int) -> void:
	self.coordinates.x = x
	self.coordinates.y = y


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
	var captured_x = (
		self.coordinates.x - 1 if self.coordinates.x - 2 == move.x else self.coordinates.x + 1
	)
	var captured_y = (
		self.coordinates.y - 1 if self.coordinates.y - 2 == move.y else self.coordinates.y + 1
	)
	var captured = board[captured_x][captured_y]
	if captured == BLACK_MAN and self.white or captured == WHITE_MAN and not self.white:
		return true
	return false


func available_captures(board) -> Array:
	var direction = -1 if self.white else 1
	var avail_captures = []
	var move = Vector2i(self.coordinates.x + direction * 2, self.coordinates.y + 2)
	if _check_capture(move, board):
		avail_captures.push_back(move)
	move.y = self.coordinates.y - 2
	if _check_capture(move, board):
		avail_captures.push_back(move)
	return avail_captures


func _check_move(move, board) -> bool:
	if move.x < 0 or move.x >= SIZE or move.y < 0 or move.y >= SIZE:  #out of board
		return false
	var cell = board[move.x][move.y]
	if cell != NO_MAN:  # can't go on non-empty cell
		return false
	return true


func available_moves(board) -> Array:
	var direction = -1 if self.white else 1
	var avail_moves = []
	var move = Vector2i(self.coordinates.x + direction, self.coordinates.y + 1)
	if _check_move(move, board):
		avail_moves.push_back(move)
	move.y = self.coordinates.y - 1
	if _check_move(move, board):
		avail_moves.push_back(move)
	return avail_moves
