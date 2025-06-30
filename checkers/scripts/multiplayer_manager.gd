extends Node

signal peer_ready
signal peer_disconnected_signal(id)
signal all_peers_connected

var ip
var port

var peer: ENetMultiplayerPeer
var host: bool = false
var connected_peers: Array = []
var max_players: int = 2
var connection_attempted: bool = false


func _ready():
	var config = ConfigFile.new()

	# WINDOWS C:\Users\<TuoNomeUtente>\AppData\Roaming\Godot\app_userdata\<NomeProgetto>\
	# LINUX /home/<tuo_utente>/.local/share/godot/app_userdata/<NomeProgetto>/
	# IOS /var/mobile/Containers/Data/Application/<UUID>/Documents/
	# ANDROID /sdcard/Android/data/org.godotengine.tuo_gioco/files/config.cfg

	var path = "user://config.cfg"
	if not FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_line("[network]")
		file.store_line('ip="127.0.0.1"')
		file.store_line("port=12345")
		file.close()
	if config.load(path) != OK:
		print("Error in config file opening")
		return
	self.ip = config.get_value("network", "ip", "127.0.0.1")  # default is localhost
	self.port = config.get_value("network", "port", 12345)  # default is 12345
	self.peer = ENetMultiplayerPeer.new()


func is_host():
	return self.host


func connection():
	connection_attempted = true

	$Connecting.start()

	# Prova a connettersi come client
	var result = self.peer.create_client(ip, port)
	if result != OK:
		print("Client error: becoming server", result)
		_fallback_to_server()
		return

	self.multiplayer.multiplayer_peer = peer

	# Connetti tutti i segnali necessari
	self.multiplayer.peer_connected.connect(_on_peer_connected)
	self.multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	self.multiplayer.connected_to_server.connect(_on_connected_to_server)
	self.multiplayer.connection_failed.connect(_on_connection_failed)  # IMPORTANTE!


func _on_peer_connected(id):
	$Connecting.stop()
	if host:
		print("Peer connected. ID:", id)
		connected_peers.append(id)
		# Emetti il segnale quando abbiamo abbastanza giocatori
		if connected_peers.size() >= (max_players - 1):
			emit_signal("peer_ready")
			emit_signal("all_peers_connected")
	else:
		print("Peer connected. ID:", id)
		emit_signal("peer_ready")
		emit_signal("all_peers_connected")


func _on_peer_disconnected(id):
	print("Peer disconnected. ID:", id)
	connected_peers.erase(id)
	emit_signal("peer_disconnected_signal", id)


func _on_connected_to_server():
	$Connecting.stop()
	emit_signal("peer_ready")


func _on_connection_failed():
	$Connecting.stop()
	_fallback_to_server()


func _on_connecting_timeout() -> void:
	_fallback_to_server()


func _fallback_to_server():
	if host:  # Se già siamo server, non fare nulla
		return

	# Pulisci la connessione precedente
	_cleanup_connection()

	# Crea un nuovo peer per il server
	self.peer = ENetMultiplayerPeer.new()
	var result = self.peer.create_server(port, max_players)

	if result != OK:
		print("Error in server creation: ", result)
		return

	self.host = true

	# Configura il multiplayer per il server
	self.multiplayer.multiplayer_peer = peer

	# Riconnetti i segnali per il server
	if not self.multiplayer.peer_connected.is_connected(_on_peer_connected):
		self.multiplayer.peer_connected.connect(_on_peer_connected)
	if not self.multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		self.multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Il server è pronto immediatamente
	emit_signal("peer_ready")


func _cleanup_connection():
	# Disconnetti i segnali se connessi
	if self.multiplayer.peer_connected.is_connected(_on_peer_connected):
		self.multiplayer.peer_connected.disconnect(_on_peer_connected)
	if self.multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		self.multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
	if self.multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		self.multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	if self.multiplayer.connection_failed.is_connected(_on_connection_failed):
		self.multiplayer.connection_failed.disconnect(_on_connection_failed)

	# Chiudi la connessione esistente
	if self.multiplayer.multiplayer_peer:
		self.multiplayer.multiplayer_peer.close()
		self.multiplayer.multiplayer_peer = null


func get_connected_peers() -> Array:
	return connected_peers.duplicate()


func get_total_players() -> int:
	return connected_peers.size() + 1  # +1 per il giocatore locale
