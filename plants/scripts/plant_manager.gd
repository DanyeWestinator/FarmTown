extends Node2D
class_name Plant_Manager

@export var tick_time = 1

@onready var ground = $"../Ground"
@onready var debug_label : Label = $Label
@export var tillable = [Vector2i(5, 0), Vector2i(5, 1)]
@export var dirt = [Vector2i(6, 0), Vector2i(6, 1)]
const plant_prefab = preload("res://plants/scenes/plant.tscn")

var spawned_plants = {}

var _current_time = 0
func _process(delta: float) -> void:
	if _current_time >= tick_time:
		_tick()
		_current_time = 0
	else:
		_current_time += delta
	
var tick_count = 0
func _tick() -> void:
	tick_count += 1
	debug_label.text = "Tick count: " + str(tick_count)
	for coord in spawned_plants:
		_tick_plant(spawned_plants[coord])

func _tick_plant(plant : Node2D):
	var anim : AnimatedSprite2D = plant.find_child("AnimatedSprite2D")
	anim.frame += 1

func Coords_From_World(world : Vector2) -> Vector2i:
	var cell = ground.to_local(world)
	cell = ground.local_to_map(cell)
	return cell

var changed_tiles = Dictionary()

func PlacePlantAt(coords):
	var atlas = ground.get_cell_atlas_coords(coords)
	if atlas == Vector2i(-1, -1): return
	if atlas not in dirt: return
	if coords in spawned_plants: return
	_place_plant_rpc.rpc(coords)
	
	
@rpc("any_peer", "call_local")
func _place_plant_rpc(coords):
	var plant = plant_prefab.instantiate()
	spawned_plants[coords] = plant
	plant.name = str(coords)
	plant.show()
	var mult_manager = $"../MultiplayerManager"
	mult_manager.add_child(plant)
	var pos = ground.map_to_local(coords)
	pos = ground.to_global(pos)
	plant.position = pos
	
var _tile_sources : Dictionary
func TrySetTile(coords : Vector2i, atlas : Vector2i, layer : int = 3) -> bool:
	if coords in changed_tiles and changed_tiles[coords] == atlas:
		return false
	var td = ground.get_cell_tile_data(coords)
	if td == null: 
		print("Tile was null @ ", coords)
		return false
	var texture = ground.get_cell_atlas_coords(coords)
	if coords not in _tile_sources:
		_tile_sources[coords] = texture
	if texture not in tillable: 
		return false
	__set_cell.rpc(coords, atlas, layer)
	return true

@rpc("any_peer", "call_local")
func __set_cell(coords : Vector2i, atlas : Vector2i, layer : int = 3) -> void:
	changed_tiles[coords] = atlas
	ground.set_cell(coords, layer, atlas)


func _on_player_joined(peer_id : int):
	_player_joined_rpc.rpc_id(peer_id, changed_tiles)
	for coord in spawned_plants:
		var plant : Node2D = spawned_plants[coord]
		var anim : AnimatedSprite2D = plant.get_node("AnimatedSprite2D")
var _joined = false
@rpc("authority", "call_remote")
func _player_joined_rpc(tiles : Dictionary):
	changed_tiles = tiles
	for coord in changed_tiles:
		ground.set_cell(coord, 3, tiles[coord])
	_joined = true
