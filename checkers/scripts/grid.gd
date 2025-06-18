extends GridContainer

const TILE_SCENE = preload("res://scenes/tile.tscn")
const MAN_SCENE = preload("res://scenes/man.tscn")

const COLUMNS = 8
const ROWS = 8
enum {PLAYER_MAN, IA_MAN, NO_MAN}
var last_board = []
var selected_piece = null
var first_update = true
var man_reference: Man

signal move_selected

func _ready():
	# update()
	_create_matrix(ROWS,COLUMNS)

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
	
func print_board(board):
	print("PLAYER: 0\nIA: 1\nVOID: 2\n")
	for i in range(ROWS):
		print("\nROWS "+str(i+1)+": ")
		print(board[i])

func update(board):
	print_board(board)
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
				self.last_board[x][y] = board[x][y]
			elif board[x][y] != self.last_board[x][y]:
				print("np")
				var tile = self.get_cell(x,y)
				#print(tile.get_coordinates())
				var removed_man = tile.get_child(0)
				if removed_man:
					tile.remove_child(removed_man)
					removed_man.queue_free()
					print("si")
				if board[x][y] != NO_MAN:
					var container_and_man = _create_man(board[x][y])
					container_and_man[1].set_coordinates(x, y)
					tile.add_child(container_and_man[0])
				self.last_board[x][y] = board[x][y]
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
		#self.man_reference.deselect()
