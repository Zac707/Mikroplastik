extends Line2D

# === VARIABLE DECLARATIONS ===
var points_amount = 20        # Total number of segments in the snake
var speed = 200              # Pixels per second the head moves toward mouse
var length = 10            # Distance between each segment
var target_pos = Vector2.ZERO # Initialize target_pos properly
var position_history = []   # Array storing every position the head has visited
var history_spacing = 2.0   # Smaller spacing = more precise following, less stiff
var max_turn_angle = 360.0   # Higher angle = less stiff turning
var last_direction = Vector2.UP  # Previous movement direction of the head

@export var Textures: Array[Sprite2D]
@export var Hitbox: Area2D
@export var Ground: Area2D
@export var Ground_Texture: PackedScene
@export var root: Node2D
@export var score_manager: LocalScore


func _ready():
	Textures[0].position = points[0]
	Textures[0].rotation += PI
	var t = get_point_position(points_amount - 1)
	var p = get_point_position(points_amount - 2)
	Textures[1].position = points[20]
	Textures[1].rotation = t.angle_to_point(p) + PI
	Ground_Texture.instantiate()
	manual_init()

func manual_init():
	# … your existing clear_points() + add_point() loop …

	# Build a perfectly-spaced history so no spring-out happens
	position_history.clear()
	var pt_count = get_point_count()
	var steps_per_seg = int(length / history_spacing)

	# For each adjacent pair of points, subdivide that exact length
	for i in range(pt_count - 1):
		var A = get_point_position(i)
		var B = get_point_position(i + 1)
		var dir = (B - A).normalized()
		# drop steps_per_seg entries between A→B
		for s in range(steps_per_seg):
			position_history.append(A + dir * (s * history_spacing))

	# finally tack on the very last point (the tail)
	position_history.append(get_point_position(pt_count - 1))

	# optional: extend beyond tail if you need “more past”
	var tail_dir = (get_point_position(pt_count - 1)
					- get_point_position(pt_count - 2)).normalized()
	for j in range(50):
		var last = position_history[position_history.size() - 1]
		position_history.append(last + tail_dir * history_spacing)


func _process(delta):
	if target_pos.length() == 0:
		return

	# Move head with turn limiting
	var head_pos = get_point_position(0)
	var move_dist = min(target_pos.length(), speed * delta)
	var desired_dir = target_pos.normalized()
	var angle_diff = clamp(
		last_direction.angle_to(desired_dir),
		-deg_to_rad(max_turn_angle) * delta,
		deg_to_rad(max_turn_angle) * delta
	)
	last_direction = last_direction.rotated(angle_diff)
	var new_head_pos = head_pos + last_direction * move_dist
	set_point_position(0, new_head_pos)

	# Evenly-spaced history sampling
	if position_history.size() == 0:
		position_history.push_front(new_head_pos)
	else:
		var last_hist = position_history[0]
		var dist = new_head_pos.distance_to(last_hist)
		if dist >= history_spacing:
			var dir = (new_head_pos - last_hist).normalized()
			var steps = int(dist / history_spacing)
			for s in range(steps):
				last_hist += dir * history_spacing
				position_history.push_front(last_hist)

	# Update followers from history
	var pt_count = get_point_count()
	var entries_per_seg = int(length / history_spacing)
	for i in range(1, pt_count):
		var idx = i * entries_per_seg
		if idx < position_history.size():
			set_point_position(i, position_history[idx])
		else:
			var prev_pos = get_point_position(i - 1)
			var curr_pos = get_point_position(i)
			var dir = (curr_pos - prev_pos).normalized()
			set_point_position(i, prev_pos + dir * length)

	# Trim old history
	var max_hist = pt_count * entries_per_seg + 10
	if position_history.size() > max_hist:
		position_history.resize(max_hist)

	# Update textures & hitbox
	if Textures.size() >= 2:
		var h = get_point_position(0)
		var n = get_point_position(1)
		Textures[0].position = h
		Textures[0].rotation = h.angle_to_point(n)

		var t = get_point_position(pt_count - 1)
		var p = get_point_position(pt_count - 2)
		Textures[1].position = t
		Textures[1].rotation = t.angle_to_point(p) + PI

		Hitbox.position = h



func get_input(dir: Vector2):
	# Scale the direction to make movement more responsive
	target_pos = dir * 10.0  # Multiply by a factor to increase sensitivity
