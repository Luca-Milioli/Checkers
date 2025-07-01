extends "res://addons/gut/test.gd"

const man_scene := preload("res://scenes/man.tscn")

var man_container
var man: Man

func before_each():
	man_container = man_scene.instantiate()
	man = man_container.get_node("Man")

func after_each():
	man_container.queue_free()

func test_flip_should_set_flip_v_true():
	# Verifica valore iniziale
	assert_false(man.flip_v, "Inizialmente il nodo non dovrebbe essere flippato.")
	
	man_container.flip()
	
	assert_true(man.flip_v, "Dopo il flip(), flip_v deve essere true.")

func test_has_point_returns_true_inside_area():
	man.size = Vector2(40, 40)

	var inside_point = Vector2(5, 5)
	assert_true(man_container._has_point(inside_point), "Punto all'interno dovrebbe ritornare true.")

func test_has_point_returns_false_outside_area():
	man.size = Vector2(40, 40)

	var outside_point = Vector2(1000, 1000)
	assert_false(man_container._has_point(outside_point), "Punto molto lontano dovrebbe ritornare false.")

func test_piece_clicked_signal_is_emitted():
	var signal_result := {"emitted": false, "value": null}

	man_container.connect("piece_clicked", Callable(self, "_on_piece_clicked").bind(signal_result))
	
	var click = InputEventMouseButton.new()
	click.pressed = true
	click.button_index = MOUSE_BUTTON_LEFT
	
	man_container._on_gui_input(click)

	assert_true(signal_result["emitted"], "Il segnale piece_clicked dovrebbe essere emesso.")
	assert_eq(signal_result["value"], man_container.get_node("Man"), "Il segnale dovrebbe passare il nodo 'Man'.")

func _on_piece_clicked(piece_node, signal_result: Dictionary):
	signal_result["emitted"] = true
	signal_result["value"] = piece_node
