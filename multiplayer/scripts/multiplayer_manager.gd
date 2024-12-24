extends Node2D

signal on_game_started

const PORT = 6969
var enet_peer = ENetMultiplayerPeer.new()
@onready var main_menu = $MainMenu
@onready var plant_manager = $"../Plant_Manager"
const player_prefab = preload("res://player/scenes/player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		print("Graceful shutdown")
		get_tree().quit()


func _on_start_pressed() -> void:
	main_menu.hide()
	_host()
	on_game_started.emit()

func _on_joined_pressed() -> void:
	main_menu.hide()
	_join()
	on_game_started.emit()
	
	
func _host() -> void:
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_connected.connect(plant_manager._on_player_joined)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	
func _join():
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = player_prefab.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
