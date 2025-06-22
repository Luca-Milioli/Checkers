class_name GameLogic

signal move_ready
signal player_changed(player)
signal piece_moved(old_cell, new_cell, done)
signal capture(cell)
signal new_king(old_cell)
signal new_moves(moves)
signal animation_done

const SIZE = 8
enum {WHITE_MAN, WHITE_KING, NO_MAN, BLACK_MAN, BLACK_KING}

var board = []
var grid : Board
var winner : int
var player1 : Player
var player2: Player
var old_cell : Vector2i
var new_cell : Vector2i
var available_moves = {}
var available_captures = {}

func set_players(player1: Player, player2: Player):
	self.player1 = player1
	self.player2 = player2

func connect_to_target(receiver):
	self.player_changed.connect(receiver._player_changed)
	self.piece_moved.connect(receiver._on_piece_moved)
	self.capture.connect(receiver._on_capture)
	self.new_king.connect(receiver._on_new_king)
	self.new_moves.connect(receiver._on_new_moves)

func setup_matrix() -> void:
	_create_matrix(SIZE, SIZE)
	for x in range(SIZE):
		for y in range(SIZE):
			board[x][y] = NO_MAN
			if (not bool((x + y)%2)):
				if x < 3:
					board[x][y] = BLACK_MAN
				elif x > 4:
					board[x][y] = WHITE_MAN

func print_board():
	print("PLAYER: 0\nIA: 1\nVOID: 2\n")
	for i in range(SIZE):
		print("\nROWS "+str(i+1)+": ")
		print(board[i])

func _create_matrix(rows, cols):
	for x in range(rows):
		var col = []
		for y in range(cols):
			col.append(null)
		self.board.append(col)

func _check_move() -> bool:
	var old_cell_key = make_key(self.old_cell.x, self.old_cell.y)
	if self.available_captures.has(old_cell_key) and self.available_captures[old_cell_key].has(self.new_cell)\
		or self.available_moves.has(old_cell_key) and self.available_moves[old_cell_key].has(self.new_cell):
			return true
	return false

func _set_move():
	var man_moving = self.board[self.old_cell.x][self.old_cell.y]
	self.board[self.new_cell.x][self.new_cell.y] = man_moving
	self.board[self.old_cell.x][self.old_cell.y] = NO_MAN
	if abs(new_cell.y - old_cell.y) == 2:		# capture
		var capture_cell = Vector2i(max(self.old_cell.x, self.new_cell.x) - 1, max(self.old_cell.y, self.new_cell.y) - 1)
		self.board[capture_cell.x][capture_cell.y] = NO_MAN
		self.capture.emit(capture_cell)
	if new_cell.x == SIZE - 1 and man_moving == BLACK_MAN or new_cell.x == 0 and man_moving == WHITE_MAN:
		self.board[self.new_cell.x][self.new_cell.y] = WHITE_KING if self.player1.is_playing() else BLACK_KING
		self.new_king.emit(old_cell)

func _change_turn():
	self.player1.set_playing(not self.player1.is_playing())
	self.player2.set_playing(not self.player2.is_playing())
	self.player_changed.emit(self.player1.is_playing())

func _make_move():
	var move_made = false
	var multi_move = true
	while multi_move:
		await self.move_ready
		if _check_move():
			_set_move()
			self.piece_moved.emit(old_cell, new_cell, self.animation_done)
			await self.animation_done
			move_made = true
			multi_move = not self.available_captures.is_empty()
			if multi_move:
				var captures = _single_man_available_captures(new_cell.x, new_cell.y)
				if not captures.is_empty():
					self.available_captures[make_key(new_cell.x, new_cell.y)] = captures
				else:
					self.available_captures = {}
				multi_move = not self.available_captures.is_empty()
	return move_made

func _check_winner() -> int:
	if available_captures.is_empty() and available_moves.is_empty():
		return 2 if self.player1.is_playing() else 1
	return 0
	
func _update_available_moves():
	var all_moves
	if not _new_available_captures():
		_new_available_moves()
		all_moves = self.available_moves
	else:
		available_moves = {}
		all_moves = self.available_captures
	self.new_moves.emit(all_moves)
	
func game_start():
	self.player1.set_playing(true)
	self.player2.set_playing(false)
	_update_available_moves()
	while not self.winner:
		if await _make_move():
			_change_turn()
			_update_available_moves()
			self.winner = _check_winner()
	return self.winner

func get_board():
	return self.board

func set_grid(grid):
	self.grid = grid

func _on_move_selected(old, new):
	self.old_cell = old
	self.new_cell = new
	self.move_ready.emit()

func _single_man_available_captures(x, y):
	return self.grid.get_cell(x, y).get_child(0).get_child(0).available_captures(self.board)

func _new_available_captures():
	self.available_captures = {}
	for x in range(SIZE):
		for y in range(SIZE):
			if self.board[x][y] != NO_MAN and (self.board[x][y] <= WHITE_KING) == self.player1.is_playing():
				var man_captures = _single_man_available_captures(x, y)
				if not man_captures.is_empty():
					self.available_captures[make_key(x, y)] = man_captures
	if self.available_captures.is_empty():
		return false
	return true

func _single_man_available_moves(x, y):
	return self.grid.get_cell(x, y).get_child(0).get_child(0).available_moves(self.board)

func _new_available_moves():
	self.available_moves = {}
	for x in range(SIZE):
		for y in range(SIZE):
			if self.board[x][y] != NO_MAN and (self.board[x][y] <= WHITE_KING) == self.player1.is_playing():
				var man_moves = _single_man_available_moves(x, y)
				if not man_moves.is_empty():
					self.available_moves[make_key(x, y)] = man_moves

func make_key(x, y) -> String:
	return "%d,%d" % [x, y]
