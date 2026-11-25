class_name Winch
extends Node2D

## Emitted when the arc_distance is changed by player input.
signal distance_changed(change: float)

@export var _also_check_mouse_input: bool

@export var _handle: Node2D
@export var _handle_area: Area2D
@export var _center: Node2D

var ignore_input: bool = false:
	set (value):
		ignore_input = value
		if _drag_handler:
			_drag_handler.ignore_input = value

var arc_distance: float:
	set (value):
		arc_distance = value
		#print("New: " + str(arc_distance))

var in_use: bool:
	get:
		if !_drag_handler:
			return false
		return _drag_handler.is_dragging


var _radius: float
var _circumference: float
var _start_dir: Vector2
var _previous_angle: float

var _drag_handler: AreaDragHandler


func _ready() -> void:
	_radius = _center.global_position.distance_to(_handle.global_position)
	_circumference = 2 * PI * _radius
	
	_start_dir = (_handle.global_position - _center.global_position).normalized()
	_previous_angle = (_handle.position - _center.position).angle()
	
	_drag_handler = AreaDragHandler.new()
	_drag_handler.setup(_handle_area, null, _also_check_mouse_input, false)
	_drag_handler.drag_moved.connect(_on_drag_moved)


func _input(event: InputEvent) -> void:
	_drag_handler.handle_input(event)


func _on_drag_moved(pos: Vector2) -> void:
	set_closest_on_circle(pos)


## Sets the handle of the winch to the closes position on its radius
## to the given global position.
## Also adds the distance moved this way to the arc_distance
func set_closest_on_circle(global_pos: Vector2) -> void:
	# Get local directional vector and angle
	var local_dir := global_pos - _center.global_position
	var angle := local_dir.angle()
	
	# Snap handle
	_handle.global_position = _center.global_position + local_dir.normalized() * _radius
	
	var delta_angle := _angle_difference(_previous_angle, angle)
	if abs(delta_angle) > 4:
		printerr("Winch delta angle unrealistically high! delta: " + str(delta_angle) + \
		" angle: " + str(angle) + \
		" prev_angle: " + str(_previous_angle))
	_previous_angle = angle
	
	var delta_distance := _radius * delta_angle
	arc_distance += delta_distance
	distance_changed.emit(delta_distance)


# Smallest difference between two angles, in radians
func _angle_difference(a: float, b: float) -> float:
	var diff := fposmod((b - a) + PI, TAU) - PI
	return diff




## Moves the handle so that arc_distance reaches the given absolute target value.
## The handle will smoothly interpolate over `duration` seconds.
func move_to_distance(target_distance: float, duration: float = 1.0) -> void:
	if duration <= 0.0:
		push_warning("Duration must be > 0")
		duration = 1.0
	
	var start_distance := arc_distance
	var tween := get_tree().create_tween()
	
	tween.tween_method(
		func(current_distance: float):
			set_handle_to_distance(current_distance),
		start_distance, target_distance, duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Helper: snap handle to the circle according to arc distance
func set_handle_to_distance(distance: float) -> void:
	arc_distance = distance
	# Convert arc distance -> angle
	var angle := distance / _radius
	# Place handle on circle at that angle
	_handle.global_position = _center.global_position + _start_dir.rotated(angle) * _radius
	_previous_angle = angle
