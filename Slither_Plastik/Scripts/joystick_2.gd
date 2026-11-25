extends Area2D

var _drag_handler: AreaDragHandler
@export var _touch_area: Area2D
@export var _also_check_mouse_input: bool
@export var worm: Line2D
@onready var stick = $stick
@export var joystick : Sprite2D
var max_distance: float = 30.0
var origin_position: Vector2
var direction : Vector2

func _ready() -> void:
	_drag_handler = AreaDragHandler.new()
	_drag_handler.setup(_touch_area, self, _also_check_mouse_input)
	_drag_handler.drag_started.connect(_on_drag_started)
	_drag_handler.drag_moved.connect(_on_drag_moved)
	_drag_handler.drag_ended.connect(_on_drag_ended)
	origin_position = stick.global_position

func _input(event: InputEvent) -> void:
	_drag_handler.handle_input(event)


func _on_drag_started(_pos: Vector2) -> void:
	pass


func _on_drag_moved(_pos: Vector2) -> void:
	direction = stick.global_position - origin_position

	if direction.length() > max_distance:
		direction = direction.normalized() * max_distance

	self.global_position = origin_position + direction
	joystick.global_position = origin_position

	if worm:
		worm.get_input(direction)

func _on_drag_ended(_result: AreaDragHandler.DragResult) -> void:
	self.global_position = origin_position
	joystick.global_position = origin_position

	if worm:
		worm.get_input(Vector2.ZERO)
