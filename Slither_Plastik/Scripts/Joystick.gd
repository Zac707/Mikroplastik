extends Area2D

var dragging: bool = false
var origin_position: Vector2
var max_distance: float = 30.0
var offset:  Vector2
var direction := Vector2.ZERO
@export var worm: Line2D
@export var timer : Timer
@onready var stick = $stick

var index_of_input: int 
var instance
var moveable = false

func _ready():
	origin_position = stick.global_position

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		dragging = true
		offset = event.position - global_position
		timer.start()

	if (event is InputEventScreenTouch and event.pressed):
		# Start dragging
		dragging = true
		offset = event.position - global_position
		timer.start()
		index_of_input = event.index

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseMotion:
		var current_position = event.position
		stick.global_position = current_position - offset
		direction = stick.global_position - origin_position

		if direction.length() > max_distance:
			direction = direction.normalized() * max_distance

		stick.global_position = origin_position + direction			
		# Send input to worm if it exists
		if worm:
			worm.get_input(direction)

	if dragging and event is InputEventScreenDrag and event.index == index_of_input:
		var current_position = event.position
		stick.global_position = current_position - offset
		direction = stick.global_position - origin_position

		if direction.length() > max_distance:
			direction = direction.normalized() * max_distance

		stick.global_position = origin_position + direction			
		# Send input to worm if it exists
		if worm:
			worm.get_input(direction)


	elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or event is InputEventScreenTouch:
		if not event.pressed:
			dragging = false
			stick.global_position = origin_position
			direction = Vector2.ZERO
			
			# Stop worm movement when joystick is released
			if worm:
				worm.get_input(Vector2.ZERO)

	elif event is InputEventScreenTouch and event.index == index_of_input:
		if not event.pressed:
			dragging = false
			stick.global_position = origin_position
			direction = Vector2.ZERO
			
			# Stop worm movement when joystick is released
			if worm:
				worm.get_input(Vector2.ZERO)

func _on_timer_timeout() -> void:
	moveable = true
