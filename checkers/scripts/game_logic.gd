class_name GameLogic

signal move_ready
signal player_changed(player)
signal piece_moved(new_cell)
signal capture(cell)
signal new_king(old_cell)

const SIZE = 8
enum {PLAYER_MAN, IA_MAN, NO_MAN}

var board = []
var grid : Board
var white_turn : bool
var winner : int
var old_cell : Vector2i
var new_cell : Vector2i
var available_moves
var available_captures

func connect_to_target(receiver):
	self.player_changed.connect(receiver._player_changed)
	self.piece_moved.connect(receiver._on_piece_moved)
	self.capture.connect(receiver._on_capture)
	self.new_king.connect(receiver._on_new_king)

# METTI IN CLASSE PLAYER
var seconds: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.seconds = 600

func format_time() -> void:
	var minutes = self.seconds / 60
	var secs = self.seconds % 60
	self.text = "%02d:%02d" % [minutes, secs]

func _on_update_label_timeout() -> void:
	self.seconds -= 1
	self.format_time()

func setup_matrix() -> void:
	_create_matrix(SIZE, SIZE)
	for x in range(SIZE):
		for y in range(SIZE):
			board[x][y] = NO_MAN
			if (not bool((x + y)%2)):
				if x < 3:
					board[x][y] = IA_MAN
				elif x > 4:
					board[x][y] = PLAYER_MAN

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
	var old_cell_key = vec2i_to_key(self.old_cell)
	if self.available_captures.has(old_cell_key) and self.available_captures[old_cell_key].has(self.new_cell)\
		or self.available_moves.has(old_cell_key) and self.available_moves[old_cell_key].has(self.new_cell):
			return true
	return false

func _set_move():
	self.board[self.old_cell.x][self.old_cell.y] = NO_MAN
	self.board[self.new_cell.x][self.new_cell.y] = int(not self.white_turn)
	if abs(new_cell.y - old_cell.y) == 2:		# capture
		var capture_cell = Vector2i(max(self.old_cell.x, self.new_cell.x) - 1, max(self.old_cell.y, self.new_cell.y) - 1)
		self.board[capture_cell.x][capture_cell.y] = NO_MAN
		self.capture.emit(capture_cell)
	if new_cell.x == 7 and not self.white_turn or new_cell.x == 0 and self.white_turn:
		self.new_king.emit(old_cell)

func _change_turn():
	self.white_turn = not self.white_turn
	self.player_changed.emit(self.white_turn)

func _make_move():
	await self.move_ready
	if _check_move():
		_set_move()
		return true
	return false

func _check_winner() -> int:
	if available_captures.is_empty() and available_moves.is_empty():
		return 2 if self.white_turn else 1
	return 0
	
func _update_available_moves():
	if not _available_captures():
		_available_moves()
	else:
		available_moves = {}
	
func game_start():
	self.white_turn = true
	_update_available_moves()
	while not self.winner:
		if await _make_move():
			self.piece_moved.emit(old_cell, new_cell)
			_change_turn()
			_update_available_moves()
			self.winner = _check_winner()

func get_board():
	return self.board

func set_grid(grid):
	self.grid = grid

func _on_move_selected(old, new):
	self.old_cell = old
	self.new_cell = new
	self.move_ready.emit()

func _available_captures():
	self.available_captures = {}
	for x in range(SIZE):
		for y in range(SIZE):
			if self.board[x][y] != NO_MAN and bool(self.board[x][y]) != self.white_turn:
				var man = self.grid.get_cell(x, y).get_child(0).get_node("Man")
				var man_captures = man.available_captures(board)
				if not man_captures.is_empty():
					self.available_captures[vec2i_to_key(man.get_coordinates())] = man_captures
	if self.available_captures.is_empty():
		return false
	return true

func _available_moves():
	self.available_moves = {}
	for x in range(SIZE):
		for y in range(SIZE):
			if self.board[x][y] != NO_MAN and bool(self.board[x][y]) != self.white_turn:
				var man = self.grid.get_cell(x, y).get_child(0).get_node("Man")
				var man_moves = man.available_moves(board)
				if not man_moves.is_empty():
					self.available_moves[vec2i_to_key(man.get_coordinates())] = man.available_moves(board)

func vec2i_to_key(v: Vector2i) -> String:
	return "%d,%d" % [v.x, v.y]
