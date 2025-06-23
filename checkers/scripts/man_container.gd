extends Control

signal piece_clicked(piece)


func _has_point(point):
	var inflated = Rect2(Vector2(-15, -15), self.get_child(0).size + Vector2(20, 20))
	return inflated.has_point(point)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		piece_clicked.emit(get_child(0))
