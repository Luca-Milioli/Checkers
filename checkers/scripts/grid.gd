extends GridContainer

const TILE_SCENE = preload("res://scenes/tile.tscn")
const MAN_SCENE = preload("res://scenes/man.tscn")

enum {PLAYER_MAN, IA_MAN, NO_MAN}
var last_board = []
var selected_piece = null
var first_update = true

func _ready():
	# update()
	_create_matrix(8,8)

func _create_man(color):
	var man = MAN_SCENE.instantiate()
	if color == PLAYER_MAN:
		man.get_node("Man").set_image(true)
	elif color == IA_MAN:
		man.get_node("Man").set_image(false)
	return man

func get_cell(row: int, col: int) -> ColorRect:
	return self.get_child(row * 8 + col) as ColorRect

func update(board):
	var size = board.size()
	for x in range(size):
		for y in range(size):
			if first_update:
				var tile = TILE_SCENE.instantiate()
				tile.set_coordinates(x, y)
				if board[x][y] != NO_MAN:
					tile.add_child(_create_man(board[x][y]))
				tile.set_dark(not bool((x + y)%2))
				self.add_child(tile)
			elif board[x][y] != last_board[x][y]:
				last_board[x][y] = board[x][y]
				var tile = self.get_cell(x,y)
				if tile.get_child_count() == 1:
					tile.remove_child(tile.get_child(0))
				tile.add_child(_create_man(board[x][y]))
	first_update = false

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
