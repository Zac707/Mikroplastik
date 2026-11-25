class_name BioMüllMovement
extends RigidBody2D

#@export var speed: float = 350

var velocity = Vector2(0,0)
var state = 0

func setup(speed: float):
	var x_velocity = randf_range(-1.5, -0.5) * speed
	var y_velocity = randf_range(0.5, 1.5) * speed

	var array = [x_velocity, y_velocity]
	linear_velocity = Vector2(array.pick_random(), array.pick_random())
