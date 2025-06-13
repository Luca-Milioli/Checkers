extends GridContainer

const TILE_SCENE = preload("res://scenes/tile.tscn")
const MAN_SCENE = preload("res://scenes/man.tscn")

enum {PLAYER_MAN, IA_MAN, NO_MAN}
var last_board = []
var selected_piece = null

func _ready():
	# update()
	_create_matrix(8,8)
	for y in range(8):
		for x in range(8):
			var tile = TILE_SCENE.instantiate()
			tile.set_coordinates(x, y)
			
			var set_color: bool = (x + y) % 2
			tile.set_dark(not set_color)
			
			var coordinates: Vector2i = tile.get_coordinates()
			if set_color and coordinates[1] != 3 and coordinates[1] != 4:
				if coordinates[1] < 3:
					last_board[x][y] = PLAYER_MAN
				else:
					last_board[x][y] = IA_MAN
				tile.add_child(create_man(last_board[x][y]))
			else:
				last_board[x][y] = NO_MAN
				
			self.add_child(tile)

func create_man(color):
	var man = MAN_SCENE.instantiate()
	if color == PLAYER_MAN:
		man.get_node("Man").set_image(true)
	else:
		man.get_node("Man").set_image(false)
	return man

func get_cell(row: int, col: int) -> ColorRect:
	return self.get_child(row * 8 + col) as ColorRect

func update(board):
	for x in range(8):
		for y in range(8):
			if board[x][y] != last_board[x][y]:
				last_board[x][y] = board[x][y]
				var tile = self.get_cell(x,y)
				if tile.get_child_count() == 1:
					tile.remove_child(tile.get_child(0))
				tile.add_child(create_man(board[x][y]))

func _create_matrix(cols, rows):
	for y in range(cols):
		var row = []
		for x in range(rows):
			row.append(null)
		self.last_board.append(row)

func selected_cell(cell):
	if selected_piece == null:
		# Seleziona pezzo se c’è sopra un pezzo
		if last_board == NO_MAN:
			selected_piece = cell
			cell.highlight()
	else:
		# Sposta il pezzo selezionato qui
		if cell.is_empty():
			cell.set_piece(selected_piece.get_piece())
			selected_piece.clear_piece()
		selected_piece = null
