extends Node2D


@export var touch_area : Area2D

var collision_detected = false

func _on_touch_area_area_entered(area: Area2D) -> void:
	if area.has_method("real_point_count"):
		collision_detected = true


func _physics_process(delta: float) -> void:
	if collision_detected:
		var dir = touch_area.current_direction

		touch_area.global_position += -dir * 5 * delta * 60


func _on_touch_area_area_exited(area: Area2D) -> void:
	if area.has_method("real_point_count"):
		collision_detected = false
