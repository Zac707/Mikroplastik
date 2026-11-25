extends Area2D


@export var _touch_area: Area2D
@export var check_area: Area2D
@export var _also_check_mouse_input: bool
@export var line: Line2D
@export var initial_allowed_directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN]
@export var timer: Timer

var collision_detected = false
var collision_box : Area2D
var points_amount
var current_direction = Vector2.ZERO
var last_current_direction = Vector2.ZERO
var blocked_direction = Vector2.ZERO
var allowed_direction_while_inside = Vector2.ZERO
var current_pos
var in_area = false
var still_in_area
var _drag_handler: AreaDragHandler
var direction_history : Array = []


func _ready() -> void:
	_drag_handler = AreaDragHandler.new()
	_drag_handler.setup(_touch_area, self, _also_check_mouse_input)
	_drag_handler.drag_started.connect(_on_drag_started)
	_drag_handler.drag_moved.connect(_on_drag_moved)
	_drag_handler.drag_ended.connect(_on_drag_ended)
	points_amount = line.get_point_count()
	update_touch_area_position()


func _input(event: InputEvent) -> void:
	if _drag_handler != null:
		_drag_handler.handle_input(event)


func _on_drag_started(_pos: Vector2) -> void:
	pass


func _on_drag_moved(_pos: Vector2) -> void:
	# If we have no points, nothing to do
	if points_amount <= 0:
		return

	var last_index = points_amount - 1
	var last_point = line.points[last_index]
	var second_last_point = line.points[last_index - 1] if last_index > 0 else null

	# Read the touch area position (AreaDragHandler should update this)
	current_pos = _touch_area.position
	update_touch_area_position()

	# Check if touch is too far from the last point - if so, stop control. commented due to game feel being hindered by this
	# if current_pos.distance_to(last_point) > 15:
		# return

	# Direction locking logic (determine proposed_direction from the motion)
	var diff = current_pos - last_point
	var proposed_direction: Vector2
	if abs(diff.x) > abs(diff.y):
		proposed_direction = Vector2.RIGHT if diff.x > 0 else Vector2.LEFT
	else:
		proposed_direction = Vector2.DOWN if diff.y > 0 else Vector2.UP

	# If we're inside a collision area, only allow the single direction which is opposite
	# to the direction with which the other area was entered (allowed_direction_while_inside).
	if in_area:
		# If allowed_direction_while_inside hasn't been set, block movement.
		if allowed_direction_while_inside == Vector2.ZERO:
			return

		# Only accept movement if the player moves in the allowed opposite direction.
		if proposed_direction != allowed_direction_while_inside:
			return

		# Accept the allowed direction and set it as current_direction.
		collision_detected = false
		current_direction = proposed_direction
		if still_in_area == false:
			in_area = false
		# Continue to applying movement (skip history gating while inside).
	else:
		# Normal gating using initial_allowed_directions / direction_history
		if current_direction == Vector2.ZERO and points_amount == 2:
			if proposed_direction in initial_allowed_directions:
				current_direction = proposed_direction
				last_current_direction = current_direction
			else:
				return  # Don't allow movement in this direction
		elif current_direction == Vector2.ZERO and points_amount > 2:
			var last_direction = direction_history.size() - 1
			if last_direction >= 0 and proposed_direction in direction_history[last_direction]:
				current_direction = proposed_direction
				last_current_direction = current_direction
			else:
				return  # Don't allow movement in this direction

	# Calculate the new position based on locked direction
	var new_position = last_point
	if current_direction == Vector2.RIGHT or current_direction == Vector2.LEFT:
		new_position = Vector2(current_pos.x, last_point.y)
	elif current_direction == Vector2.DOWN or current_direction == Vector2.UP:
		new_position = Vector2(last_point.x, current_pos.y)

	# Check if the new position is back at the second-to-last point
	if second_last_point and new_position.distance_to(second_last_point) < 15:
		current_direction = Vector2.ZERO
		line.points[last_index] = second_last_point
		return

	# Apply the new position
	line.points[last_index] = new_position


func _on_drag_ended(_result: AreaDragHandler.DragResult) -> void:
	self.position = line.points[points_amount - 1]
	# Do not immediately reset current_direction here!


func get_entry_point() -> Vector2:
	var last_point = line.points[points_amount -1]
	var prev_point = line.points[points_amount - 2]
	var entry_point = (prev_point - last_point).normalized()
	
	return entry_point


func get_exit_point() -> Vector2:
	var last_point = line.points[points_amount -1]
	var prev_point = line.points[points_amount - 2]
	var exit_point = (last_point - prev_point).normalized()
	
	return exit_point


func real_point_count(point_count):
	points_amount = point_count
	update_touch_area_position()
	# Lock direction based on last two points, if possible
	if points_amount > 1:
		var last = line.points[points_amount - 1]
		var prev = line.points[points_amount - 2]
		var diff = last - prev
		if abs(diff.x) > abs(diff.y):
			current_direction = Vector2.RIGHT if diff.x > 0 else Vector2.LEFT
			last_current_direction = current_direction
		else:
			current_direction = Vector2.DOWN if diff.y > 0 else Vector2.UP
			last_current_direction = current_direction
	else:
		current_direction = Vector2.ZERO

	# USER REQUEST: reset the allowed_direction_while_inside only when direction_history
	# is updated (we assume real_point_count is called when the history/points change).
	# Clear the "inside" restriction here so normal movement resumes after the line/history update.
	allowed_direction_while_inside = Vector2.ZERO
	blocked_direction = Vector2.ZERO
	in_area = false


func update_touch_area_position():
	if points_amount > 0:
		_touch_area.position = line.points[points_amount - 1]


func _closest_cardinal_direction(norm_vec: Vector2) -> Vector2:
	if norm_vec == Vector2.ZERO:
		return Vector2.ZERO
	var cardinals = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	var best = Vector2.ZERO
	var best_dot = -2.0
	for c in cardinals:
		var d = norm_vec.dot(c)
		if d > best_dot:
			best_dot = d
			best = c
	return best


func _on_collision_area_area_entered(area: Area2D) -> void:
	if area.has_method("real_point_count") and area.get_parent() != self.get_parent():
		# Mark that we're inside a collision area.
		in_area = true
		collision_detected = true

		# Compute the normalized difference of their global positions and choose the closest cardinal.
		# We use the other area's global_position and this node's global_position.
		var other_global = area.global_position
		var my_global = self.global_position
		var diff = (other_global - my_global)
		var dir_norm = Vector2.ZERO
		if diff.length() > 0.0:
			dir_norm = diff.normalized()

		# blocked_direction is the cardinal direction closest to (other - self).
		# The allowed direction while inside is its opposite.
		blocked_direction = _closest_cardinal_direction(dir_norm)
		allowed_direction_while_inside = -blocked_direction

		# Snap back to the last point and force movement to stop until the player moves in the allowed direction.
		if points_amount > 0:
			var last_index = points_amount - 1
			_touch_area.position = line.points[last_index]
			line.points[last_index] = line.points[last_index]
		# clear current_direction so the player must deliberately choose the allowed direction
		current_direction = Vector2.ZERO


func _on_collision_area_area_exited(area: Area2D) -> void:
	if area.has_method("real_point_count") and area.get_parent() != self.get_parent():
		# Leaving the area: mark that we've left physically, but don't lift the movement restriction here.
		# The restriction (allowed_direction_while_inside) is now cleared only when direction_history/points
		# are updated via real_point_count().
		still_in_area = false
		if collision_detected == false:
			in_area = false
		# NOTE: intentionally do NOT clear allowed_direction_while_inside or blocked_direction here.
