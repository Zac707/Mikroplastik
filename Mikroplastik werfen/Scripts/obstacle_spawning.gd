extends Node2D

@export var scene_to_spawn: PackedScene
@export var spawn_position: Vector2 = Vector2.ZERO
@export var obstacle_speed: int 


func spawn_scene():
	var instance = scene_to_spawn.instantiate()
	if instance is Node2D:
		instance.position = spawn_position
		instance.speed = obstacle_speed
	add_child(instance)

func _on_timer_timeout() -> void:
	spawn_scene()
