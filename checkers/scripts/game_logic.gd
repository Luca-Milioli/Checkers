class_name GameLogic

signal update_gui

const COLUMNS = 8
const ROWS = 8
enum {PLAYER_MAN, IA_MAN, NO_MAN}
var board = []
var player_turn : bool
var winner : int

func connect_to_target(receiver):
	self.update_gui.connect(receiver.update.bind(self.board))
	
	
func setup_matrix() -> void:
	_create_matrix(ROWS, COLUMNS)
	for x in range(ROWS):
		for y in range(COLUMNS):
			board[x][y] = NO_MAN
			if (not bool((x + y)%2)):
				if x < 3:
					board[x][y] = PLAYER_MAN
				elif x > 4:
					board[x][y] = IA_MAN

func print_board():
	print("PLAYER: 0\nIA: 1\nVOID: 2\n")
	for i in range(ROWS):
		print("\nROWS "+str(i+1)+": ")
		print(board[i])

func _create_matrix(cols, rows):
	for y in range(cols):
		var row = []
		for x in range(rows):
			row.append(null)
		self.board.append(row)

func _check_move(old: Vector2i, new: Vector2i) -> bool:
	return true

func _set_move(old: Vector2i, new: Vector2i):
	self.board[old[0]][old[1]] = self.board[new[0]][new[1]]
	
func _change_turn():
	self.player_turn = !player_turn

func _make_move():
	var move_passed = false
	var old_cell : Vector2i
	var new_cell : Vector2i
	while not move_passed:
		old_cell = Vector2i(0, 0)
		new_cell = Vector2i(0, 1)
		move_passed = _check_move(old_cell, new_cell)
	_set_move(old_cell, new_cell)

func _check_winner() -> int:
	return 1	
	
func game_start():
	
	while not self.winner:
		_change_turn()
		_make_move()
		update_gui.emit()
		self.winner = _check_winner()
		
		
		
