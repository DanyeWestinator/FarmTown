extends Node2D
signal start_pressed
signal join_pressed

func _ready() -> void:
	var host_button : Button = $VBoxContainer/Host
	host_button.grab_focus()

var _has_started : bool = false
func _start_pressed() -> void:
	if _has_started: return
	_has_started = true
	start_pressed.emit()


func _join_pressed() -> void:
	join_pressed.emit()
