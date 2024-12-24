extends Node
class_name ToolType

@export var inv_sprite : Texture2D
@export var atlas_coords : Vector2i
@export var anim_prefix : String
@export var anim_speed : float = 2
@onready var player : Player = $"../.."
@onready var seed_particles : GPUParticles2D = $"../../ToolSprite/SeedParticles"

func Use(selected_cell : Vector2i) -> void:
	if "Shovel" in str(name):
		_use_shovel(selected_cell)
	if "Seeds" in str(name):
		_use_seeds(selected_cell)
	if "Scythe" in str(name):
		player.animator.play()

func FinishUse(selected_cell : Vector2i) -> void:
	if "Shovel" in str(name):
		_finish_shovel(selected_cell)
	if "Seeds" in str(name):
		_finish_use_seeds(selected_cell)

		
func _use_shovel(selected_cell : Vector2i): 
	player.animator.play()
func _finish_shovel(selected_cell : Vector2i) -> void:
	var dirt = Vector2i(6, 1)
	player.plants.TrySetTile(selected_cell, dirt)

func _use_seeds(_selected_cell : Vector2i):
	player.animator.play()
	seed_particles.restart()
	seed_particles.emitting = true
	
func _finish_use_seeds(selected_cell : Vector2i):
	player.plants.PlacePlantAt(selected_cell)
	seed_particles.emitting = false
