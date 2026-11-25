extends Area2D

var dragging: bool = false
var origin_position: Vector2
var max_distance: float = 100.0
var offset :Vector2
var direction := Vector2.ZERO
var index_of_input: int 

@export var obj : PackedScene
@export var RNG = Node2D
@export var guideline : Line2D

func _ready():
	origin_position = self.global_position


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		dragging = true
		offset = event.position - global_position

	if (event is InputEventScreenTouch and event.pressed):
		# Start dragging
		dragging = true
		offset = event.position - global_position
		index_of_input = event.index


func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseMotion:
		var current_position = event.position
		global_position = current_position - offset
		direction = global_position - origin_position

		if direction.y < 0:
			direction.y = 0

		if direction.length() > max_distance:
			direction = direction.normalized() * max_distance

		global_position = origin_position + direction
		rotation = direction.angle() + deg_to_rad(-90)
		
		update_trajectory_line()
		

	if dragging and event is InputEventScreenDrag and event.index == index_of_input:
		var current_position = event.position
		global_position = current_position - offset
		direction = global_position - origin_position

		if direction.y < 0:
			direction.y = 0

		if direction.length() > max_distance:
			direction = direction.normalized() * max_distance

		global_position = origin_position + direction
		rotation = direction.angle() + deg_to_rad(-90)
		
		update_trajectory_line()

	elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if not event.pressed:
			rotation = 0.0

			if direction.length() >= 20.0 and dragging:
				var instance = obj.instantiate()
				instance.shoot(direction, RNG.rng_array[RNG.current_index])
				get_parent().add_child(instance)

				if RNG.current_index >= 5:
					RNG.stop()
					print(RNG.Hitbox.visible)
				elif RNG.current_index < RNG.rng_array.size():
					RNG.current_index += 1
					RNG.show_sprite_for_number(RNG.rng_array[RNG.current_index])

			dragging = false
			global_position = origin_position
			direction = global_position - origin_position
			guideline.clear_points()

	elif event is InputEventScreenTouch:
		if not event.pressed and event.index == index_of_input:
			rotation = 0.0

			if direction.length() >= 20.0 and dragging:
				var instance = obj.instantiate()
				instance.shoot(direction, RNG.rng_array[RNG.current_index])
				get_parent().add_child(instance)

				if RNG.current_index >= 5:
					RNG.stop()
					print(RNG.Hitbox.visible)
				elif RNG.current_index < RNG.rng_array.size():
					RNG.current_index += 1
					RNG.show_sprite_for_number(RNG.rng_array[RNG.current_index])

			dragging = false
			global_position = origin_position
			direction = global_position - origin_position
			guideline.clear_points()

func update_trajectory_line():
	if not guideline:
		return

	var points: Array = []
	var steps := 8
	var step_time := 0.1  # Time per step
	var grav := 980
	var velocity := -direction * 12  # Adjust force scale as needed
	var pos := origin_position

	for i in steps:
		points.append(pos - origin_position)  # Line2D uses local positions
		velocity.y += grav * step_time
		pos += velocity * step_time

	
	guideline.clear_points()
	guideline.add_point(Vector2.ZERO)
	guideline.add_point(direction + Vector2(0, 20)) 
	for p in points:
		guideline.add_point(p)
