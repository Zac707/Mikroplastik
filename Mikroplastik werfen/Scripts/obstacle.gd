extends StaticBody2D

@export var speed : float = 5.0

func _process(delta: float):
	global_position.x += speed
