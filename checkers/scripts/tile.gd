extends ColorRect

signal tile_clicked(tile)

var x: int
var y: int
var show_circle = false


func set_dark(dark: bool) -> void:
	color = Color(0.2, 0.2, 0.2) if dark else Color(0.8, 0.8, 0.8)


func get_coordinates():
	return Vector2i(self.x, self.y)


func set_coordinates(x: int, y: int) -> void:
	self.x = x
	self.y = y


func flip():
	var man_container = self.get_child(0)
	if man_container:
		man_container.flip()


func _draw():
	if show_circle:
		var radius = min(size.x, size.y) * 0.2
		var center = size / 2
		draw_circle(center, radius, Color(0.5, 0.82, 0.5, 0.8))


func show_move_hint():
	show_circle = true
	queue_redraw()


func hide_move_hint():
	show_circle = false
	queue_redraw()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tile_clicked.emit(self)
