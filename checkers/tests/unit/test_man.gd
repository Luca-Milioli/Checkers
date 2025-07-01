extends "res://addons/gut/test.gd"

const man_scene := preload("res://scenes/man.tscn")

var man: Man

func before_each():
	man = man_scene.instantiate().get_node("Man")

func after_each():
	man.get_parent().queue_free()

func test_attributes():
	man.set_white(true)
	man.set_image("res://art/white_man.png")
	man.set_coordinates(4,6)
	man.select()
	
	assert_true(man.is_selected(), "Should be selected")
	assert_eq(man.modulate, man.CLICK_MODULATE, "Should be highlighted")
	
	man.deselect()
	
	assert_false(man.is_selected(), "Should not be selected")
	assert_eq(man.modulate, man.DEFAULT_MODULATE, "Should be highlighted")
