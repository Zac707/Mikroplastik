class_name PlastikMüllMovement
extends RigidBody2D


## Emitted when the plastic was found and clicked/tapped
signal clicked


@export var button: TextureButton


func setup(speed: float):
	var positive_speed = randf_range(-1, -0.5) * speed
	var negative_speed = randf_range(1, 0.5) * speed

	var speeds = [positive_speed, negative_speed]
	linear_velocity = Vector2(speeds.pick_random(), speeds.pick_random())
	
	button.pressed.connect(_on_pressed)



func _on_pressed() -> void:
	clicked.emit()
	queue_free()
