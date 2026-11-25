class_name GameOverUI
extends Control


@export var _restart_button: Button

var restart_delegate: Callable


func setup(p_restart_delegate: Callable) -> void:
	restart_delegate = p_restart_delegate
	_restart_button.pressed.connect(_on_restart_pressed)


func _on_restart_pressed() -> void:
	print("\nRestarting game!")
	restart_delegate.call()
