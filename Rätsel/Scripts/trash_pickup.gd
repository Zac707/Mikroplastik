extends Area2D


@export var trash: Sprite2D
@onready var grey_shader = trash.material

var trash_collected = false
var entry_extremity: int = -1
const RADIUS := 38.0
signal points_earned(amount)

func get_extremities(center: Vector2) -> Array:
	# Returns the 4 extremity points (top, right, bottom, left)
	return [
		center + Vector2(0, -RADIUS),     # Top
		center + Vector2(RADIUS, 0),      # Right
		center + Vector2(0, RADIUS),      # Bottom
		center + Vector2(-RADIUS, 0)      # Left
	]

func closest_extremity(center: Vector2, point: Vector2) -> int:
	var extremities = get_extremities(center)
	var min_dist = INF
	var min_index = -1
	for i in extremities.size():
		var dist = extremities[i].distance_to(point)
		if dist < min_dist:
			min_dist = dist
			min_index = i
	return min_index # 0=Top, 1=Right, 2=Bottom, 3=Left

func _ready() -> void:
	trash.material = null

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Line_Rätsel") and not trash_collected:
		var center = global_position
		entry_extremity = closest_extremity(center, area.global_position)
		print("Entry extremity: ", entry_extremity)
		trash.material = grey_shader
		trash.position += Vector2(-20, 20)
		trash_collected = true
		area.points_earned += 1

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Line_Rätsel") and trash_collected:
		var center = global_position
		var exit_extremity = closest_extremity(center, area.global_position)
		print("Exit extremity: ", exit_extremity)
		if exit_extremity == entry_extremity:
			trash.material = null
			trash.position += Vector2(20, -20)
			trash_collected = false
			area.points_earned -= 1
		else:
			print("Exit direction does not match entry; effect not triggered.")
