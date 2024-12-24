extends Node
class_name InventoryManager

@onready var test_item : Control = $InventoryItem
@onready var player : Player = $".."
const InventoryItemPrefab = preload("res://player/scenes/InventoryItem.tscn")
@export var spacing : float = 140
@export var Tools : Array[ToolType]
var _is_inv_open = false

func InventoryPressed():
	if _is_inv_open:
		_hide()
	else:
		_show()
	_is_inv_open = !_is_inv_open
	
func _hide():
	for item in get_children():
		item.queue_free()

func _show():
	_load_inv()

const INV_POSITIONS = [Vector2(0, -1), Vector2(1, -1),
 Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)]

func _load_inv():
	var i = 0
	for item in Tools:
		var gui : Control = InventoryItemPrefab.instantiate()
		var texture : TextureRect = gui.get_node("TextureRect")
		texture.texture = item.inv_sprite
		var label : Label = gui.get_node("Label")
		label.text = item.name
		var button : Button = gui.get_node("Button")
		button.pressed.connect(_on_button_pressed.bind(item))
		add_child(gui)
		gui.position = INV_POSITIONS[i] * spacing
		i += 1
		
func _on_button_pressed(tool : ToolType):
	player.SetTool(tool)
