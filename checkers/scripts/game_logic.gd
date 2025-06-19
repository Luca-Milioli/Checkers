class_name GameLogic

signal update_gui  # $Board/Grid
signal move_ready
signal player_changed(player)

const SIZE = 8
enum {PLAYER_MAN, IA_MAN, NO_MAN}

var board = []
var white_turn : bool
var winner : int
var old_cell : Vector2i
var new_cell : Vector2i
var available_moves = []

func connect_to_target(receiver):
	self.update_gui.connect(receiver._update.bind(self.board))
	self.player_changed.connect(receiver._player_changed)

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

func _create_matrix(cols, rows):
	for y in range(cols):
		var row = []
		for x in range(rows):
			row.append(null)
		self.board.append(row)

func _check_move() -> bool:
	if available_moves.has(new_cell):
		return true
	return false

func _set_move():
	self.board[self.old_cell.x][self.old_cell.y] = NO_MAN
	self.board[self.new_cell.x][self.new_cell.y] = int(not self.white_turn)
	if abs(new_cell.y - old_cell.y) == 2:		# capture
		self.board[max(self.old_cell.x, self.new_cell.x) - 1] \
			[max(self.old_cell.y, self.new_cell.y) - 1] = NO_MAN
	
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
	return 0
	
func game_start():
	self.white_turn = true
	self.player_changed.emit(self.white_turn)
	update_gui.emit()
	while not self.winner:
		if await _make_move():
			update_gui.emit()
			_change_turn()
			self.winner = _check_winner()
	
func _on_move_selected(old, new, available_moves):
	self.old_cell = old
	self.new_cell = new
	self.available_moves = available_moves
	self.move_ready.emit()

func _get_old_cell():
	return self.board[self.old_cell[0]][self.old_cell[1]]

func _get_new_cell():
	return self.board[self.new_cell[0]][self.new_cell[1]]
