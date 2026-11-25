extends Line2D

@export var target: Node2D  

var point_index := 1        # The index of the point that should follow the target
var offset_x
var offset_y
var radius = 30
var dir : Vector2

func _process(_delta: float) -> void:
	if not target or points.size() <= point_index:
		return

	# Update the designated point to follow the target
	var updated_points = points
	
	updated_points[point_index] = to_local(target.global_position) 
	points = updated_points
