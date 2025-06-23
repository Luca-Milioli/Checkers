extends TextureRect

class_name Man

enum { WHITE_MAN, WHITE_KING, NO_MAN, BLACK_MAN, BLACK_KING }

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


func _deep_copy_board(board):
	var copy = []
	for row in board:
		copy.append(row.duplicate(true))  # deep copy
	return copy


func calculate_captures(board: Array) -> Array:
	var all_sequences = []
	var current_path = [self.coordinates]
	_capture_recursive(self.coordinates, board, current_path, all_sequences)
	print(all_sequences)
	return all_sequences


func _capture_recursive(position: Vector2i, board, path: Array, all_sequences: Array) -> void:
	var direction = -1 if self.white else 1
	var capture_dirs = [Vector2i(direction * 2, 2), Vector2i(direction * 2, -2)]

	var has_captured = false
	for offset in capture_dirs:
		var target = position + offset
		if _check_capture_from(position, target, board):
			has_captured = true
			var captured_x = position.x + offset.x / 2
			var captured_y = position.y + offset.y / 2
			var captured_piece = board[captured_x][captured_y]
			var board_copy = _deep_copy_board(board)
			board_copy[captured_x][captured_y] = NO_MAN
			board_copy[target.x][target.y] = board_copy[position.x][position.y]
			board_copy[position.x][position.y] = NO_MAN
			var new_path = path.duplicate()
			new_path.append(target)

			_capture_recursive(target, board_copy, new_path, all_sequences)

	if not has_captured and path.size() > 1:
		var current_len = path.size()
		if all_sequences.is_empty():
			all_sequences.append(path)
		else:
			var existing_len = all_sequences[0].size()
			if current_len > existing_len:
				all_sequences.clear()
				all_sequences.append(path)
			elif current_len == existing_len:
				all_sequences.append(path)


func _check_capture_from(from: Vector2i, to: Vector2i, board: Array) -> bool:
	if not _check_move(to, board):
		return false
	var captured_x = from.x + (to.x - from.x) / 2
	var captured_y = from.y + (to.y - from.y) / 2
	if captured_x < 0 or captured_x >= 8 or captured_y < 0 or captured_y >= 8:
		return false
	var captured = board[captured_x][captured_y]
	if captured == BLACK_MAN and self.white or captured == WHITE_MAN and not self.white:
		return true
	return false


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
	if move.x < 0 or move.x >= 8 or move.y < 0 or move.y >= 8:  #out of board
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
