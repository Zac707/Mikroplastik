class_name FishingRB
extends RigidBody2D


## Emitted when a fishable object was attached to this hook
signal object_attached(obj: FishableObject)
signal object_detached


@export var _touch_area: Area2D
@export var _also_check_mouse_input: bool

@export_group("Pulling In")
@export var _anchor: Node2D
@export var _winch: Winch
@export var _winch_strength: float = 1.0

# Pulling in is with
@export_group("Reeling In")
## The reel in speed after pressing the button in pixels/s
@export var _reel_in_speed: float = 200.0
@export var _reel_in_scale_curve: Curve
@export var _reel_in_speed_curve: Curve
@export var _reel_in_scale_multi: float = 1.5
@export var _fishable_obj_container: Node2D

## Set by the Throw Area
var left_throw_area: bool = false

## Wether the RB is currently flying away from the throw area after being dragged
var flying_out: bool
var _prev_winch_distance: float = 0

var _drag_handler: AreaDragHandler

## The FishableObject attached to this hook after it was caught when reeling in.
## Is null when no FishableObject is currently caught.
var _attached_object: FishableObject = null


func _ready() -> void:
	_winch.distance_changed.connect(_move_on_winch_changed)
	
	_drag_handler = AreaDragHandler.new()
	_drag_handler.setup(_touch_area, self, _also_check_mouse_input)
	_drag_handler.drag_started.connect(_on_drag_started)
	_drag_handler.drag_ended.connect(_on_drag_ended)


func _physics_process(_delta: float) -> void:
	_apply_distance_to_winch()
	_check_flying_state()


#region Drag Input
func _input(event: InputEvent) -> void:
	if left_throw_area:
		return
	_drag_handler.handle_input(event)


func _on_drag_started(_pos: Vector2) -> void:
	freeze = true
	linear_velocity = Vector2.ZERO


func _on_drag_ended(result: AreaDragHandler.DragResult) -> void:
	freeze = false
	if result.enough_positions:
		linear_velocity = result.velocity
		flying_out = true
		#print("Applying velocity: " + str(result.velocity))


## Separate call for when this body leaves the throw area
func apply_end_drag() -> void:
	_drag_handler._stop_drag()

#endregion


func _check_flying_state() -> void:
	if !flying_out || !left_throw_area:
		return
	if linear_velocity.length() < 5:
		flying_out = false
		return
	var source_dir := (_anchor.global_position - global_position).normalized()
	if source_dir.length() == 0:
		return
	
	var dot := linear_velocity.normalized().dot(source_dir)
	if dot > -0.5:
		#printerr("Dot product of RBs linear velocity to its anchor is " + str(dot) + \
			#", which should mean that the hook is not moving away from the anchor")
		flying_out = false
		return
	


#region Reeling In
## Disables the winch. [br]
## [param hook_pos]: The global position this FishingRB (shown as a hook) should 
## 	 have to show that it is attached. [br]
## [param hook_rot]: The global rotation this FishingRB (shown as a hook) should have 
##	 to show that it is attached.
func attach_object(obj: FishableObject, hook_pos: Vector2, hook_rot: float) -> void:
	_attached_object = obj
	_winch.ignore_input = true
	
	await get_tree().process_frame
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	global_position = hook_pos
	global_rotation = hook_rot
	
	await get_tree().process_frame
	freeze = false
	
	object_attached.emit(obj)


func detach_object() -> void:
	for child in _fishable_obj_container.get_children():
		child.queue_free()
	_attached_object = null
	_winch.ignore_input = false
	object_detached.emit()


func has_attached_object() -> bool:
	return _attached_object != null


## Reparents this hooks _attached_object to the hook if reparent_obj is true.
## Starts a tween to reel the hook to the location of its anchor,
## or to the given alt_target_pos.
func reel_in_object(
		reparent_obj: bool = true,
		alt_target_pos: Vector2 = Vector2(-1, -1)
	) -> void:
	if !left_throw_area || flying_out:
		return
	if !_attached_object:
		push_error("Fishing hook " + name + " had no attached object when reel_in was called")
		return
	if !_attached_object.has_enough_players():
		push_error("Fishable object does not have enough attached players!")
		return
	
	print("REELING IN")
	freeze = true
	if reparent_obj:
		_attached_object.reparent(_fishable_obj_container, true)
		_attached_object.ready_for_reel_in()
	
	var target_pos := _anchor.global_position
	if alt_target_pos != Vector2(-1, -1):
		target_pos = alt_target_pos
	var original_scale := scale
	var start_pos := global_position
	
	_do_reel_in_tween(start_pos, target_pos, original_scale, reparent_obj)


func _do_reel_in_tween(
		start_pos: Vector2, target_pos: Vector2,
		original_scale: Vector2, start_minigame: bool
	) -> void:
	var dist = global_position.distance_to(target_pos)
	var duration = dist / _reel_in_speed
	
	var tween := get_tree().create_tween()
	tween.set_parallel()
	
	tween.tween_method(
		func(value):
			var t = _reel_in_speed_curve.sample_baked(value)
			global_position = start_pos.lerp(target_pos, t)
	, 0.0, 1.0, duration)

	tween.tween_method(
		func(value):
			var factor = 1 + _reel_in_scale_curve.sample_baked(value) * _reel_in_scale_multi
			scale = original_scale * factor
	, 0.0, 1.0, duration)

	tween.finished.connect(func() -> void:
		freeze = false
		if start_minigame:
			_attached_object.start_minigame()
		detach_object())

#endregion


#region Pulling In
func _move_on_winch_changed(change: float) -> void:
	if change < 0:
		return
	if !left_throw_area || flying_out || _attached_object != null:
		return
	
	var full_dir := _anchor.global_position - global_position
	if full_dir.length() < 0.2:
		return
	if full_dir.length() < change:
		change = full_dir.length()
	
	freeze = false
	var dir := full_dir.normalized()
	var strength := change * _winch_strength
	
	#print("Applying impulse, dir: " + str(dir) + ", str: " + str(strength))
	apply_impulse(dir * strength, Vector2.UP.rotated(rotation) * 13)
	#apply_central_impulse(dir * strength)


func _apply_distance_to_winch() -> void:
	if _winch.in_use:
		return
	
	var distance := global_position.distance_to(_anchor.global_position)
	var delta: float = abs(distance - _prev_winch_distance)
	
	if delta < 0.5:
		return
	_winch.set_handle_to_distance(distance)
	_prev_winch_distance = distance


#endregion
