@tool
class_name ConnectionLine2D
extends Line2D

@export var target: Node2D:
	set (value):
		target = value
		_update_line()

@export var offset: Vector2:
	set (value):
		offset = value
		_update_line()

var latest_target_position: Vector2
var latest_global_position: Vector2


func _physics_process(_delta: float) -> void:
	if !is_inside_tree():
		return
	if target == null:
		return
	if target.global_position == latest_target_position && global_position == latest_global_position:
		return
	latest_target_position = target.global_position
	latest_global_position = global_position
	
	_update_line()

func _update_line() -> void:
	if target == null:
		points.clear()
		return
	
	points[0] = Vector2.ZERO
	
	var target_point: Vector2 = target.global_position + offset
	target_point = self.to_local(target_point)
	points[1] = target_point
