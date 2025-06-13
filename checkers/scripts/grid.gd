extends GridContainer

const TILE_SCENE = preload("res://scenes/tile.tscn")
const MAN_SCENE = preload("res://scenes/man.tscn")


func _ready():
	for y in range(8):
		for x in range(8):
			var tile = TILE_SCENE.instantiate()
			tile.set_coordinates(x, y)
			
			var set_color: bool = (x + y) % 2
			tile.set_dark(not set_color)
			
			var coordinates: Vector2i = tile.get_coordinates()
			if set_color and coordinates[1] != 3 and coordinates[1] != 4:
				var man = MAN_SCENE.instantiate()
				man.get_node("Man").set_image()
				if coordinates[1] < 4:
					man.get_node("Man").set_image(false)
				tile.add_child(man)
				#man.position = coordinates
				#self.add_child(man)
				#print("added man: ", man.position)
				
			self.add_child(tile)
