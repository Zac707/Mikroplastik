extends Area2D

var max_speed = 200
var ahead_distance := 40.0

func _process(_delta: float) -> void:
	var worm = get_parent()
	var p0: Vector2 = worm.points[0]
	var p1: Vector2 = worm.points[1]

	var dir: Vector2 = (p1 - p0).normalized()
	var offset: Vector2 = dir * ahead_distance

	self.position = p0 - offset

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Worked_Ground"):
		get_parent().speed += 50


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Worked_Ground"):
		get_parent().speed -= 50
