class_name AreaDragHandler
extends RefCounted
## A wrapper to handle drag input, started from an [Area2D].
##
## Usage: [br]
## Create a new instance of this class in your [method Node._ready] method. [br]
## Call [method AreaDragHandler.setup] there and connect to the 
## [signal drag_started], [signal drag_moved] and [signal drag_ended]
## signals there. [br]
## Call the [method AreaDragHandler.handle_input] method in your [Node._input]
## method.
##
## For an example implementation, see the [FishingRB] script.


## Emitted when a touch or mouse drag was started by input inside the given
## touch area. [br]
##
## Arguments: The global event.position of the InputEvent
signal drag_started(global_pos: Vector2)

## Emitted when the input that started the drag is moved. [br]
## Uses the [InputEventScreenDrag] for touch. [br]
## Uses the [InputEventMouseMotion] for mouse. [br]
##
## Arguments: The global event.position of the drag event.
signal drag_moved(global_pos: Vector2)

## Emitted when the drag input ends. See [method InputEvent.is_pressed]. [br]
## Uses the last 5 positions of the drag event and [member Engine.physics_ticks_per_second]
## to calculate the velocity of the drag at its end. [br]
##
## Arguments: A wrapper subclass. [br]
## Contains: [br]
## [member AreaDragHandler.DragResult.enough_positions] [br]
## [member AreaDragHandler.DragResult.velocity]
signal drag_ended(drag_result: DragResult)


## Offset between the input event position and the [code]target[/code] given in 
## [method AreaDragHandler.setup].
var drag_offset: Vector2 = Vector2.ZERO

var ignore_input: bool = false

var is_dragging: bool:
	get:
		return _finger_index != -1 || _mouse_dragging;

var _finger_index: int = -1
var _mouse_dragging: bool = false
var _last_positions: Array[Vector2] = []

var _use_mouse: bool = false
var _set_target_pos_when_dragging: bool = false
var _target: Node2D


## Sets up the handler with the necessary external references and settings. [br]
## Connects to the [code]touch_area's[/code] [signal Area2D.input_event] signal
## to start the drag event. [br]
##
## Parameters: [br]
## [param touch_area]: Area to use for starting the drag.
## [param target]: Node to calculate the [member AreaDragHandler.drag_offset] to.
## [param use_mouse]: Whether to also handle mouse input.
## [param move_target]: Whether to move the given target to the drag event 
## position + [member AreaDragHandler.drag_offset].
func setup(touch_area: Area2D, target: Node2D = null, use_mouse: bool = false, move_target: bool = true) -> void:
	_target = target
	_use_mouse = use_mouse
	_set_target_pos_when_dragging = move_target
	
	touch_area.input_event.connect(_on_touch_area_input)
	if use_mouse:
		touch_area.input_event.connect(_on_mouse_area_input)


# --- Input forwarding ---
## Call this in the [method Node._input] method. [br]
## Handles dragging and end of the drag event.
func handle_input(event: InputEvent) -> void:
	if ignore_input:
		return
	
	_check_touch_input(event)
	if _use_mouse:
		_check_mouse_input(event)


# --- Touch ---
func _on_touch_area_input(_vp, event: InputEvent, _shape_idx: int) -> void:
	if ignore_input:
		return
	if event is InputEventScreenTouch && event.is_pressed():
		_start_drag(event.position, event.index)


func _check_touch_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_released() && event.index == _finger_index:
		_stop_drag()
	elif event is InputEventScreenDrag && event.index == _finger_index:
		_do_drag(event.position)


# --- Mouse ---
func _on_mouse_area_input(_vp, event: InputEvent, _shape_idx: int) -> void:
	if ignore_input:
		return
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT \
			&& event.is_pressed() && !_mouse_dragging:
		_start_drag(event.position, -1, true)

func _check_mouse_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && _mouse_dragging:
		_do_drag(event.position)
	elif event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT \
			&& !event.is_pressed() && _mouse_dragging:
		_stop_drag()



# --- Shared drag logic ---
func _start_drag(pos: Vector2, finger_idx: int, mouse := false) -> void:
	_finger_index = finger_idx
	_mouse_dragging = mouse
	if _target:
		drag_offset = pos - _target.global_position
	_last_positions.clear()
	drag_started.emit(pos)


func _do_drag(pos: Vector2) -> void:
	if _set_target_pos_when_dragging && _target:
		_target.global_position = pos - drag_offset
	
	_last_positions.append(pos)
	if _last_positions.size() > 5:
		_last_positions.pop_front()
	
	drag_moved.emit(pos)


func _stop_drag() -> void:
	_finger_index = -1
	_mouse_dragging = false
	
	var result := get_drag_velocity()
	drag_ended.emit(result)
	
	_last_positions.clear()


func get_drag_velocity() -> DragResult:
	if _last_positions.size() > 1:
		var intervals := _last_positions.size() - 1
		var start := _last_positions[0]
		var end := _last_positions[-1]
		var velocity := (end - start) * Engine.physics_ticks_per_second / intervals
		return DragResult.new(true, velocity)
	
	return DragResult.new(false)




class DragResult:
	## Whether enough positions of the drag were documented to calculate
	## a velocity.
	var enough_positions: bool
	
	## The calculated velocity.
	var velocity: Vector2
	
	func _init(enough: bool, vel: Vector2 = Vector2.ZERO) -> void:
		self.enough_positions = enough
		self.velocity = vel
