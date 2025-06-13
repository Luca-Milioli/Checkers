extends GridContainer

const TILE_SCENE = preload("res://scenes/tile.tscn")


func _ready():
	for y in range(8):
		for x in range(8):
			var tile = TILE_SCENE.instantiate()
			tile.set_coordinates(x, y)
			var set_color: bool = (x + y) % 2
			tile.set_dark(not set_color)
			self.add_child(tile)
