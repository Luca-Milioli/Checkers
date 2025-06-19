extends TextureRect

class_name Man

enum {PLAYER_MAN, IA_MAN, NO_MAN}

var white
var x
var y
var _is_selected : bool
const DEFAULT_MODULATE = Color(1,1,1,1)
const CLICK_MODULATE = Color(0.4, 1, 0.8, 1)

signal piece_moved(src_cell)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._is_selected = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func connect_to_target(receiver):
	self.piece_moved.connect(receiver._on_piece_moved)

func set_image(white = true):
	var path = "res://art/white_man.jpg" if white else "res://art/black_man.jpg"
	self.white = white
	self.texture = load(path)

func set_coordinates(x: int, y: int) -> void:
	self.x = x
	self.y = y
	
func get_coordinates() -> Vector2i:
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
	
func _check_capture(move, board) -> bool:
	if not _check_move(move, board):
		return false
	var captured_x = self.x - 1 if self.white else self.x + 1
	var captured_y = self.y - 1 if self.y - 2 == move.y else self.y + 1
	var captured = board[captured_x][captured_y]
	if captured == IA_MAN and self.white or captured == PLAYER_MAN and not self.white:
		return true
	return false

func available_captures(board) -> Array:
	var direction = -1 if self.white else 1
	var avail_captures = []
	var move = Vector2i(self.x + direction * 2, self.y + 2)
	if _check_capture(move, board):
		avail_captures.push_back(move)
	move.y = self.y - 2
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
	var move = Vector2i(self.x + direction, self.y + 1)
	if _check_move(move, board):
		avail_moves.push_back(move)
	move.y = self.y - 1
	if _check_move(move, board):
		avail_moves.push_back(move)
	return avail_moves

#func _move(new_cell):
#	var old_cell = self.get_coordinates()
#	self.set_coordinates(new_cell.x, new_cell.y)
#	self.piece_moved.emit(old_cell, self.get_coordinates())
