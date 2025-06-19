extends Node
class_name Player

var _ign : String
var _man_number : int
var _white : bool
var _playing : bool
var _winner : bool

func inizialize(name: String, man_number: int, white: bool, playing: bool):
	self.set_name(name)
	self.set_man_number(man_number)
	self.set_white(white)
	self._playing = playing # evito problemi di override

func get_ign():
	return self.ign

func get_man_number():
	return self._man_number

func is_white():
	return self._white

func is_playing():
	return self._playing

func is_winner():
	return self._winner

func set_ign(name: String):
	self._ign = name
	
func set_man_number(man_number: int):
	self._man_number = man_number

func set_white(white: bool):
	self._white = white

func set_playing(playing: bool):
	self._playing = playing

func set_winner(winner: bool):
	self._winner = winner
