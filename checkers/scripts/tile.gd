extends ColorRect

var x: int
var y: int

signal tile_clicked(tile)

func set_dark(dark: bool) -> void:
	color = Color(0.2, 0.2, 0.2) if dark else Color(0.8, 0.8, 0.8)

func get_coordinates():
	return Vector2i(self.x, self.y)

func set_coordinates(x: int, y: int) -> void:
	self.x = x
	self.y = y

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tile_clicked.emit(self)
