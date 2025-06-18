class_name GameLogic

signal update_gui  # $Board/Grid
signal move_ready

const COLUMNS = 8
const ROWS = 8
enum {PLAYER_MAN, IA_MAN, NO_MAN}

var board = []
var player_turn : bool
var winner : int
var old_cell : Vector2i
var new_cell : Vector2i

func connect_to_target(receiver):
	self.update_gui.connect(receiver.update.bind(self.board))
	
func setup_matrix() -> void:
	_create_matrix(ROWS, COLUMNS)
	for x in range(ROWS):
		for y in range(COLUMNS):
			board[x][y] = NO_MAN
			if (not bool((x + y)%2)):
				if x < 3:
					board[x][y] = IA_MAN
				elif x > 4:
					board[x][y] = PLAYER_MAN

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

func _check_move() -> bool:
	return true

func _set_move():
	self.board[self.old_cell[0]][self.old_cell[1]] = NO_MAN
	self.board[self.new_cell[0]][self.new_cell[1]] = int(self.player_turn)
	print("a")
	
func _change_turn():
	self.player_turn = !player_turn

func _make_move():
	var move_passed = false
	while not move_passed:
		print("Waiting for move ... ")
		var move = await self.move_ready
		print("Move is ready")
		move_passed = _check_move()
	_set_move()


func _check_winner() -> int:
	return 0
	
func game_start():
	self.player_turn
	update_gui.emit()
	while not self.winner:
		_change_turn()
		await _make_move()
		update_gui.emit()
		self.winner = _check_winner()

func _on_move_selected(old, new):
	self.old_cell = old
	self.new_cell = new
	self.move_ready.emit()
		
