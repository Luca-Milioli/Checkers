extends Label

var seconds: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.seconds = 600

func format_time() -> void:
	var minutes = self.seconds / 60
	var secs = self.seconds % 60
	self.text = "%02d:%02d" % [minutes, secs]

func _on_update_label_timeout() -> void:
	self.seconds -= 1
	self.format_time()
