extends Node2D

class_name Man

var white
var cells_position: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start(pos, cells_pos, white):
	position = pos
	cells_position = cells_pos
	self.white = white
	$AnimatedSprite2D.animation = ("white" if white else "black")
	show()
