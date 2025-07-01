extends "res://addons/gut/test.gd"

var MultiplayerScene := preload("res://scenes/multiplayer.tscn")
var my_multiplayer

func before_each():
	my_multiplayer = MultiplayerScene.instantiate()
	add_child(my_multiplayer)
	my_multiplayer.set_process(false) # Disattiva _process se non serve

func after_each():
	my_multiplayer.queue_free()

func test_initial_state():
	assert_false(my_multiplayer.host, "Dovrebbe iniziare come client")
	assert_eq(my_multiplayer.connected_peers.size(), 0, "Nessun peer connesso all'avvio")
	assert_false(my_multiplayer.connection_attempted, "La connessione non dovrebbe essere ancora stata tentata")

func test_set_host_true_after_fallback_to_server():
	my_multiplayer._fallback_to_server()
	assert_true(my_multiplayer.is_host(), "Dopo il fallback, dovrebbe essere host")
	assert_not_null(my_multiplayer.peer, "Peer ENet dovrebbe essere stato creato")

func test_on_peer_connected_adds_peer_and_emits_signals():
	watch_signals(my_multiplayer)
	
	my_multiplayer.host = true
	my_multiplayer.max_players = 2

	my_multiplayer._on_peer_connected(42)
	
	assert_true(my_multiplayer.connected_peers.has(42), "Peer ID 42 dovrebbe essere aggiunto")
	assert_signal_emitted(my_multiplayer, "peer_ready", "peer_ready dovrebbe essere stato emesso")
	assert_signal_emitted(my_multiplayer, "all_peers_connected", "all_peers_connected dovrebbe essere stato emesso")

func test_on_peer_disconnected_removes_peer_and_emits_signal():
	watch_signals(my_multiplayer)
	
	my_multiplayer.connected_peers.append(5)

	my_multiplayer._on_peer_disconnected(5)

	assert_false(my_multiplayer.connected_peers.has(5), "Il peer disconnesso dovrebbe essere rimosso")
	assert_signal_emitted_with_parameters(my_multiplayer, "peer_disconnected_signal", [5])

func test_get_total_players_includes_self():
	my_multiplayer.connected_peers = [1, 2]
	assert_eq(my_multiplayer.get_total_players(), 3, "Deve includere anche il giocatore locale")
