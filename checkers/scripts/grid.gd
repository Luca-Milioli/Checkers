extends GridContainer

class_name Board

signal move_selected

enum { WHITE_MAN, WHITE_KING, NO_MAN, BLACK_MAN, BLACK_KING }

const TILE_SCENE = preload("res://scenes/tile.tscn")
const MAN_SCENE = preload("res://scenes/man.tscn")
const SIZE = 8

var board = []
var selected_piece = null
var man_reference: Man
var my_turn: bool
var white_turn: bool
var available_moves
var appearence_only
var my_multiplayer

func _ready():
	_create_matrix(SIZE, SIZE)


func connect_to_target(receiver):
	self.move_selected.connect(receiver._on_move_selected)


func set_appearence_only(appearence: bool = false):
	self.appearence_only = appearence


func set_board(board):
	self.board = board


func set_multiplayer(my_multiplayer):
	self.my_multiplayer = my_multiplayer


func _create_tile(x, y):
	var tile = TILE_SCENE.instantiate()
	tile.connect("tile_clicked", Callable(self, "_on_tile_clicked"))
	tile.set_coordinates(x, y)
	tile.set_dark(not bool((x + y) % 2))

	if self.board[x][y] != NO_MAN:
		var container_and_man = _create_man(x, y)
		container_and_man[1].set_coordinates(x, y)
		tile.add_child(container_and_man[0])
	self.add_child(tile)


func _create_man(x, y):
	var man_container = MAN_SCENE.instantiate()
	man_container.connect("piece_clicked", Callable(self, "_on_piece_clicked"))
	var man = man_container.get_node("Man")
	var color = self.board[x][y]

	if color == WHITE_MAN:
		man.set_white(true)
		man.set_image("res://art/white_man.png")
	elif color == BLACK_MAN:
		man.set_white(false)
		man.set_image("res://art/black_man.png")
	return [man_container, man]


func get_cell(row: int, col: int) -> ColorRect:
	return self.get_child(row * SIZE + col) as ColorRect


func print_board():
	print("PLAYER: 0\nIA: 1\nVOID: 2\n")
	for i in range(SIZE):
		print("\nROWS " + str(i + 1) + ": ")
		print(self.board[i])


func setup_gui(new_board):
	set_board(new_board)
	for x in range(SIZE):
		for y in range(SIZE):
			_create_tile(x, y)

	var children = self.get_child_count()
	self.move_child($Move, children - 1)
	self.move_child($Capture, children - 1)
	self.move_child($Promotion, children - 1)


func flip():
	for child in self.get_children():
		if child is ColorRect:
			child.flip()


func _create_matrix(rows, cols):
	for x in range(rows):
		var col = []
		for y in range(cols):
			col.append(null)
		self.board.append(col)


func _on_piece_clicked(piece):
	if not my_turn:
		return
	if not self.appearence_only:
		var legal = self.my_turn and self.white_turn == piece.is_white()
		if self.man_reference:
			self.man_reference.deselect()
			_hide_moves_hint()
			self.man_reference = null
		if legal:
			self.man_reference = piece
			self.man_reference.select()
			_show_moves_hint()

@rpc("any_peer")
func _on_tile_clicked(tile, man_coord = null, tile_coord = null, synchronize = false):
	if not my_turn and not synchronize:
		return
	if synchronize:
		tile = get_cell(man_coord.x, man_coord.y)
		self.man_reference = tile.get_child(0).get_child(0) # man 2, 4 | tile 3, 4
	elif not self.man_reference:
		return
	else:
		tile_coord = tile.get_coordinates()
		man_coord = self.man_reference.get_coordinates()

	if tile_coord != man_coord:
		if self.man_reference.is_selected():
			self.move_selected.emit(man_coord, tile_coord)
			if not synchronize:
				_on_tile_clicked.rpc(null, man_coord, tile_coord, true)

func _animations(object, ending_value, param = "global_position", time = 0.2):
	object.visible = true
	if object is Control:
		object.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(object, param, ending_value, time)
	await tween.finished


func _on_piece_moved(old_cell, new_cell, done):
	var old_tile = self.get_cell(old_cell.x, old_cell.y)
	var new_tile = self.get_cell(new_cell.x, new_cell.y)

	var moved_man_container = old_tile.get_child(0)
	var tmp_copy = moved_man_container.duplicate()
	tmp_copy.z_index = 1

	old_tile.remove_child(moved_man_container)

	old_tile.add_child(tmp_copy)

	var offset = old_tile.global_position - tmp_copy.global_position
	var new_position = new_tile.global_position - offset
	$Move.play()
	await self._animations(tmp_copy, new_position)
	old_tile.remove_child(tmp_copy)
	tmp_copy.queue_free()

	new_tile.add_child(moved_man_container)

	var moved_man = moved_man_container.get_child(0)
	moved_man.set_coordinates(new_cell.x, new_cell.y)
	moved_man.deselect()
	_hide_moves_hint()
	
	done.emit()


func _on_capture(cell):
	var tile = self.get_cell(cell.x, cell.y)
	var captured_man_container = tile.get_child(0)
	$Capture.play()

	await _animations(captured_man_container, Color(1, 1, 1, 0), "modulate", 0.8)

	tile.remove_child(captured_man_container)
	captured_man_container.queue_free()


func _on_new_king(old_cell):
	$Promotion.play()
	var tile = self.get_cell(old_cell.x, old_cell.y)
	var man_container = tile.get_child(0)
	var man = man_container.get_child(0)
	var image = "res://art/white_king.png" if man.is_white() else "res://art/black_king.png"
	var king = TextureRect.new()
	king.set_script(load("res://scripts/king.gd"))
	king.set_image(image)
	king.inherit_from_man(man)
	man_container.remove_child(man)
	man.queue_free()
	man_container.add_child(king)
	self.man_reference = king
	if my_turn and not white_turn or not my_turn and white_turn:
		tile.flip()

func _player_changed(peer_id, white_turn):
	self.my_turn = self.my_multiplayer.multiplayer.get_unique_id() == peer_id
	self.white_turn = white_turn


func _on_new_moves(moves: Dictionary):
	self.available_moves = moves


func _show_moves_hint():
	var man_coord = self.man_reference.get_coordinates()
	for k in available_moves:
		if from_string_to_Vec2i(k) == man_coord:
			for move in available_moves[k]:
				self.get_cell(move.x, move.y).show_move_hint()


func _hide_moves_hint():
	for i in range(SIZE):
		for j in range(SIZE):
			self.get_cell(i, j).hide_move_hint()


func from_string_to_Vec2i(s: String) -> Vector2i:
	return Vector2i(int(s[0]), int(s[2]))
