extends TextureRect

class_name Man

var white
var x
var y
var is_selected : bool
const DEFAULT_MODULATE = Color(1,1,1,1)
const CLICK_MODULATE = Color(0.4, 1, 0.8, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.is_selected = false
	self.white = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_image(white = true):
	var path = "res://art/white_man.jpg" if white else "res://art/black_man.jpg"
	self.texture = load(path)

func set_coordinates(x: int, y: int) -> void:
	self.x = x
	self.y = y
	
func get_coordinates():
	return Vector2i(self.x, self.y)

func select():
	self.modulate = self.CLICK_MODULATE
	self.is_selected = true

func deselect():
	self.modulate = self.DEFAULT_MODULATE
	self.is_selected = false
	
