extends GridContainer

class_name Board

const TILE_SCENE = preload("res://scenes/tile.tscn")
const MAN_SCENE = preload("res://scenes/man.tscn")

const SIZE = 8
enum {PLAYER_MAN, IA_MAN, NO_MAN}
var board = []
var selected_piece = null
var man_reference: Man
var white_turn = true # 1 white, 0 black

signal move_selected

func _ready():
	_create_matrix(SIZE, SIZE)

func connect_to_target(receiver):
	self.move_selected.connect(receiver._on_move_selected)

func set_board(board):
	self.board = board

func _create_tile(x, y):
	var tile = TILE_SCENE.instantiate()
	tile.connect("tile_clicked", Callable(self, "_on_tile_clicked"))
	tile.set_coordinates(x, y)
	tile.set_dark(not bool((x + y)%2))
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
	if color == PLAYER_MAN:
		man.set_white(true)
		man.set_image()
	elif color == IA_MAN:
		man.set_white(false)
		man.set_image()
	return [man_container, man]

func get_cell(row: int, col: int) -> ColorRect:
	return self.get_child(row * SIZE + col) as ColorRect
	
func print_board():
	print("PLAYER: 0\nIA: 1\nVOID: 2\n")
	for i in range(SIZE):
		print("\nROWS "+str(i+1)+": ")
		print(self.board[i])

func setup_gui(new_board):
	set_board(new_board)
	for x in range(SIZE):
		for y in range(SIZE):
			_create_tile(x, y)

func _create_matrix(rows, cols):
	for x in range(rows):
		var col = []
		for y in range(cols):
			col.append(null)
		self.board.append(col)

func _on_piece_clicked(piece):
	var legal = white_turn == piece.is_white()
	
	if self.man_reference:
		self.man_reference.deselect()
		self.man_reference = null
	if legal:
		self.man_reference = piece
		self.man_reference.select()
		
func _on_tile_clicked(tile):
	if not self.man_reference:
		return
	var tile_coord = tile.get_coordinates()
	var man_coord = self.man_reference.get_coordinates()
	if tile_coord != man_coord:
		if(self.man_reference.is_selected()):
			self.move_selected.emit(man_coord, tile_coord)

func _on_piece_moved(old_cell, new_cell):
	var old_tile = self.get_cell(old_cell.x, old_cell.y)
	var new_tile = self.get_cell(new_cell.x, new_cell.y)
	var moved_man_container = old_tile.get_child(0)
	old_tile.remove_child(moved_man_container)
	new_tile.add_child(moved_man_container)
	var moved_man = moved_man_container.get_node("Man")
	moved_man.set_coordinates(new_cell.x, new_cell.y)
	moved_man.deselect()

func _on_capture(cell):
	var tile = self.get_cell(cell.x, cell.y)
	var captured_man_container = tile.get_child(0)
	tile.remove_child(captured_man_container)
	captured_man_container.queue_free()

func _on_new_king(old_cell):
	var tile = self.get_cell(old_cell.x, old_cell.y)
	var man_container = tile.get_child(0)
	var man = man_container.get_child(0)
	var king = King.new()
	king.inherit_from_man(man)
	man_container.remove_child(man)
	man.queue_free()
	man_container.add_child(king)

func _player_changed(white_turn):
	self.white_turn = white_turn
