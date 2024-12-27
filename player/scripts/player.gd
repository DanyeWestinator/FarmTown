extends CharacterBody2D
class_name Player

@export var speed = 100

@export var max_mouse_distance = 3
@onready var camera = $Camera2D
@onready var shovel = $ToolSprite
@onready var inventory_manager : InventoryManager = $InventoryGUI
var _current_tool : Sprite2D
var _current_dir : Node2D
var ground : TileMapLayer
var gridsquares : TileMapLayer
var plants : Plant_Manager
func _enter_tree() -> void:
	var root = get_tree().root.get_child(0)
	if root is scene_manager:
		ground = root.ground
		gridsquares = root.gridsquares
		plants = root.plant_manager
	set_multiplayer_authority(str(name).to_int())
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_multiplayer_authority(): 
		return
	_current_tool = shovel
	camera.make_current()
	velocity = Vector2(0, 1)
	_movement_anim()
	SetTool(inventory_manager.Tools[0])
	

var cell
func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	cell = _current_dir.global_position
	cell = plants.Coords_From_World(cell)
	_mouse_hover(cell)
	
	if Input.is_action_just_pressed("primary_action"):
		_primary_pressed()
	if Input.is_action_just_pressed("secondary_action"):
		_secondary_pressed()
	if Input.is_action_just_pressed("inventory"):
		var inv : InventoryManager = $InventoryGUI
		inv.InventoryPressed()
	if Input.is_action_just_pressed("space"):
		var root = get_tree().root
		utilities.PrintTree(root)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	_movement(delta)
	
func _movement(delta : float):
	velocity = Vector2.ZERO
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	velocity = velocity.normalized() * speed * delta
	move_and_collide(velocity)
	_movement_anim()
	
var _anim_prefix : String = "dig"
var _last_dir : String
func _movement_anim():
	var node : Node2D = null
	if velocity.y > 0:
		$AnimatedSprite2D.animation = "down"
		node = find_child("down_tool")
	elif velocity.x > 0:
		$AnimatedSprite2D.animation = "right"
		node = find_child("right_tool")
	elif velocity.x < 0:
		$AnimatedSprite2D.animation = "left"
		node = find_child("left_tool")
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "up"
		node = find_child("up_tool")
	if node != null and node != _current_tool.get_parent():
		
		_current_dir = node
		_current_tool.global_position = node.global_position
		_current_tool.global_rotation = node.global_rotation
		_last_dir = str(node.name).replace("_tool", "")
		var dir = _anim_prefix + "_" + _last_dir
		
		animator.assigned_animation = dir
		
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
		
	else:
		$AnimatedSprite2D.stop()

func _cell_from_world(world : Vector2) -> Vector2i:
	var coords = ground.to_local(world)
	var c = ground.local_to_map(coords)
	return c

@onready var animator : AnimationPlayer = $AnimationPlayer
	
var _is_tool_anim_playing : bool = false	
func _primary_pressed():
	if _is_tool_anim_playing: return
	if inventory_manager._is_inv_open: return
	_is_tool_anim_playing = true
	_current_tooltype.Use(cell)
	
func _on_animation_finished(_anim_name: StringName) -> void:
	_current_tooltype.FinishUse(cell)
	
	_is_tool_anim_playing = false
	
func _secondary_pressed():
	pass
	
var _last_hovered_cell = Vector2i(-1111,-1111)
func _mouse_hover(coords : Vector2i):
	var td = gridsquares.get_cell_tile_data(_last_hovered_cell)
	var was_not_last = _last_hovered_cell != Vector2i(-1111,-1111)
	if was_not_last and _last_hovered_cell != coords and td:
		gridsquares.erase_cell(_last_hovered_cell)
	_last_hovered_cell = coords
	gridsquares.set_cell(coords, 4, Vector2i(0, 0))
	td = gridsquares.get_cell_tile_data(coords)
	
var _current_tooltype : ToolType
func SetTool(tool : ToolType) -> void:
	_current_tool.region_rect = Rect2(tool.atlas_coords.x, tool.atlas_coords.y, 16, 16)
	_current_tooltype = tool
	_anim_prefix = tool.anim_prefix
	animator.speed_scale = tool.anim_speed
	var dir = _anim_prefix + "_" + _last_dir
	animator.assigned_animation = dir
	

@rpc("any_peer", "call_local")
func set_tile(coords, tile):
	ground.set_cell(coords, 3, tile)
