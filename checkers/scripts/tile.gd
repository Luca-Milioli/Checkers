extends ColorRect

var x: int
var y: int

func set_dark(dark: bool) -> void:
	color = Color(0.2, 0.2, 0.2) if dark else Color(0.8, 0.8, 0.8)

func get_coordinates():
	return Vector2i(self.x, self.y)

func set_coordinates(x: int, y: int) -> void:
	self.x = x
	self.y = y
