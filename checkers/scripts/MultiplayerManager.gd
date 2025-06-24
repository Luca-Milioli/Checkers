extends Node

var peer: ENetMultiplayerPeer
var host : bool

func _ready():
	peer = ENetMultiplayerPeer.new()

func set_host(host: bool):
	self.host = host

func is_host():
	return self.host

func connection():
	if is_host():
		# Server hosting
		var port = 12345
		self.peer.create_server(port, 2)
		print("Server avviato su porta %d" % port)
	else:
		# Client connecting to server
		var ip = "127.0.0.1"
		var port = 12345
		self.peer.create_client(ip, port)
		print("Connesso a %s:%d" % [ip, port])

	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
func _on_peer_connected(id):
	print("Peer connesso con ID:", id)

func _on_peer_disconnected(id):
	print("Peer disconnesso con ID:", id)
