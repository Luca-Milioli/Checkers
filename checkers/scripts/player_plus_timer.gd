# adds a timer to the player (create a player_plus_timer object if you want
# the countdown), create player object if not

extends Player
class_name PlayerPlusTimer

signal update_label
signal time_finished

var _time_left: float

func _ready():
	$Updater.connect("timeout", Callable(self, "_on_updater_timeout"))

func connect_to_target(receiver):
	self.time_finished.connect(receiver._on_time_finished)


func set_time_left(time_left: float):
	self._time_left = time_left


func get_time_left():
	return self._time_left


func format_time() -> String:
	var minutes = self.get_time_left() / 60
	var secs = int(self.get_time_left()) % 60
	return "%02d:%02d" % [minutes, secs]


func set_playing(playing: bool):
	super.set_playing(playing)
	if playing:
		$Updater.start()
	else:
		stop_timer()

func stop_timer():
	$Updater.stop()

func _on_updater_timeout() -> void:
	self._time_left -= $Updater.wait_time
	self.update_label.emit()
	if self._time_left <= 0:
		self.time_finished.emit(self.is_white())
