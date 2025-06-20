# adds a timer to the player (create a player_plus_timer object if you want
# the countdown), create player object if not

extends Player
class_name PlayerPlusTimer

var _time_left : float
signal update_label

func set_time_left(time_left: float):
	self._time_left = time_left

func get_time_left():
	return self._time_left
	
func format_time() -> String:
	var minutes = self.get_time_left() / 60
	var secs = int (self.get_time_left()) % 60
	return "%02d:%02d" % [minutes, secs]

func set_playing(playing: bool):
	super.set_playing(playing)
	if playing:
		$Updater.start()
	else:
		$Updater.stop()

func _on_updater_timeout() -> void:
	# self.set_time_left(self.get_time_left() - 1)
	self._time_left -= $Updater.wait_time
	self.update_label.emit()
	
	
