extends TextureRect

class_name Man

var white
var cells_position: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_image(white = true):
	var path = "res://art/white_man.jpg" if white else "res://art/black_man.jpg"
	self.texture = load(path)
