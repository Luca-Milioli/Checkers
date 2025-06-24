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
var white_turn = true
var available_moves
var appearence_only


func _ready():
	_create_matrix(SIZE, SIZE)


func connect_to_target(receiver):
	self.move_selected.connect(receiver._on_move_selected)


func set_appearence_only(appearence: bool = false):
	self.appearence_only = appearence


func set_board(board):
	self.board = board


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


func _create_matrix(rows, cols):
	for x in range(rows):
		var col = []
		for y in range(cols):
			col.append(null)
		self.board.append(col)


func _on_piece_clicked(piece):
	if not self.appearence_only:
		var legal = white_turn == piece.is_white()
		if self.man_reference:
			self.man_reference.deselect()
			_hide_moves_hint()
			self.man_reference = null
		if legal:
			self.man_reference = piece
			self.man_reference.select()
			_show_moves_hint()

@rpc("any_peer")
func _on_tile_clicked(tile, man_coords_from_remote = null):
	
	var tile_coord
	var debug : String
	
	# remote call
	if tile is Vector2i and man_coords_from_remote != null:
		tile_coord = tile
		self.man_reference = get_cell(man_coords_from_remote.x, man_coords_from_remote.y).get_child(0).get_child(0)
		debug = "remote"
	# local call
	else:
		# local call but no man selected
		if not self.man_reference:
			return
		tile_coord = tile.get_coordinates()
		debug = "local"
	
	var man_coord = self.man_reference.get_coordinates()
	print("Call from "+debug, " | man_coord: "+str(man_coord)+ " | tile_coord: "+str(tile))
	
	if tile_coord != man_coord:
		if self.man_reference.is_selected():
			self.move_selected.emit(man_coord, tile_coord)
			if not man_coords_from_remote:
				print(man_coord)
				_on_tile_clicked.rpc(tile_coord, man_coord)


func _animations(object, ending_value, param = "global_position", time = 0.2):
	object.visible = true
	if object is Control:
		object.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(object, param, ending_value, time)
	await tween.finished


func _on_piece_moved(old_cell, new_cell, done = null):
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
	
	# done is only passed locally (not from remote)
	# so rpc is called only if the current player made the move
	# if piece_moved is called from remote player, rpc is not called again to avoid infinite loops
	if done != null:
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


func _player_changed(white_turn):
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
