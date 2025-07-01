extends "res://addons/gut/test.gd"

const TileScene := preload("res://scenes/tile.tscn")

var tile

func before_each():
	tile = TileScene.instantiate()

func after_each():
	tile.queue_free()

func test_set_and_get_coordinates():
	tile.set_coordinates(3, 5)
	var coords = tile.get_coordinates()
	assert_eq(coords, Vector2i(3, 5), "Coordinates should match the set values.")

func test_set_dark_true():
	tile.set_dark(true)
	assert_eq(tile.color, Color(0.2, 0.2, 0.2), "Tile should be dark when set_dark(true) is called.")

func test_set_dark_false():
	tile.set_dark(false)
	assert_eq(tile.color, Color(0.8, 0.8, 0.8), "Tile should be light when set_dark(false) is called.")

func test_show_move_hint_sets_flag_and_redraws():
	tile.show_move_hint()
	assert_true(tile.show_circle, "show_circle should be true after show_move_hint.")

func test_hide_move_hint_clears_flag():
	tile.show_move_hint()  # first turn it on
	tile.hide_move_hint()
	assert_false(tile.show_circle, "show_circle should be false after hide_move_hint.")

func test_tile_clicked_signal_is_emitted():
	watch_signals(tile)
	
	var input_event := InputEventMouseButton.new()
	input_event.pressed = true
	input_event.button_index = MOUSE_BUTTON_LEFT
	
	tile._on_gui_input(input_event)
	
	assert_signal_emitted(tile, "tile_clicked", "tile_clicked signal should be emitted on left mouse button press.")
