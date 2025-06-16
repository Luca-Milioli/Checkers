extends GridContainer

const TILE_SCENE = preload("res://scenes/tile.tscn")
const MAN_SCENE = preload("res://scenes/man.tscn")

enum {PLAYER_MAN, IA_MAN, NO_MAN}
var last_board = []
var selected_piece = null
var first_update = true
var man_reference: Man

signal move_selected


func _ready():
	# update()
	_create_matrix(8,8)

func connect_to_target(receiver):
	self.move_selected.connect(receiver._on_move_selected)
	
func _create_man(color):
	var man_container = MAN_SCENE.instantiate()
	man_container.connect("piece_clicked", Callable(self, "_on_piece_clicked"))
	
	var man = man_container.get_node("Man")

	if color == PLAYER_MAN:
		man.set_image(true)
	elif color == IA_MAN:
		man.set_image(false)
	
	return [man_container, man]

func get_cell(row: int, col: int) -> ColorRect:
	return self.get_child(row * 8 + col) as ColorRect
	

func update(board):
	#print("updating gui...")
	var size = board.size()
	for x in range(size):
		for y in range(size):
			if first_update:
				var tile = TILE_SCENE.instantiate()
				tile.connect("tile_clicked", Callable(self, "_on_tile_clicked"))
				tile.set_coordinates(x, y)
				if board[x][y] != NO_MAN:
					var container_and_man = _create_man(board[x][y])
					container_and_man[1].set_coordinates(x, y)
					tile.add_child(container_and_man[0])	
				tile.set_dark(not bool((x + y)%2))
				self.add_child(tile)
			elif board[x][y] != last_board[x][y]:
				
				var tile = self.get_cell(x,y)
				#print(tile.get_coordinates())
				if tile.get_child_count() == 1:
					tile.remove_child(tile.get_child(0))
					print("si")
					var container_and_man = _create_man(board[x][y])
					container_and_man[1].set_coordinates(x, y)
					tile.add_child(container_and_man[0])
				last_board[x][y] = board[x][y]
			else:
				print("CIAO")
	first_update = false

func _create_matrix(cols, rows):
	for y in range(cols):
		var row = []
		for x in range(rows):
			row.append(null)
		self.last_board.append(row)

func _on_piece_clicked(piece):
	if self.man_reference:
		self.man_reference.deselect()
	self.man_reference = piece
	self.man_reference.select()
	
func _on_tile_clicked(tile):
	if not self.man_reference:
		return
	
	var tile_coord = tile.get_coordinates()
	var man_coord = self.man_reference.get_coordinates()
	if tile_coord != man_coord:
		if(self.man_reference.is_selected):
			self.move_selected.emit(man_coord, tile_coord)
		self.man_reference.deselect()
