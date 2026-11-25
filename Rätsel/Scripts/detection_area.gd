extends Area2D

@export var line : Line2D
@export var control_area : Area2D

var points_amount
var current_direction = Vector2.ZERO
var point_made = false
var points_earned = 0


func _ready() -> void:
	points_amount = line.get_point_count()


func _physics_process(_delta: float) -> void:
	current_direction = control_area.current_direction
	self.position = line.points[points_amount - 1]


func create_new_point(point_position):
	line.add_point(line.to_local(point_position), points_amount- 1)
	points_amount = line.get_point_count()
	control_area.real_point_count(points_amount)


func delete_point():
	if points_amount > 1:
		line.remove_point(points_amount - 2)
		points_amount = line.get_point_count()
		control_area.real_point_count(points_amount)


func _on_area_entered(area: Area2D) -> void:
	pass
