extends Node2D
class_name Plant

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func IsMature():
	var frame = anim.frame
	var max_frame = anim.sprite_frames.get_frame_count(anim.animation) - 1
	print("On frame ", frame, " of a total of ", max_frame)
	return anim.frame == max_frame
