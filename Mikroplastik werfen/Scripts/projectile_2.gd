extends Area2D

var _drag_handler: AreaDragHandler

var max_distance: float = 100.0
var origin_position: Vector2
var direction : Vector2

@export var _touch_area: Area2D
@export var _also_check_mouse_input: bool
@export var obj : PackedScene
@export var RNG = Node2D
@export var guideline : Line2D

func _ready() -> void:
	_drag_handler = AreaDragHandler.new()
	_drag_handler.setup(_touch_area, self, _also_check_mouse_input)
	_drag_handler.drag_started.connect(_on_drag_started)
	_drag_handler.drag_moved.connect(_on_drag_moved)
	_drag_handler.drag_ended.connect(_on_drag_ended)
	origin_position = self.global_position

func _input(event: InputEvent) -> void:
	_drag_handler.handle_input(event)


func _on_drag_started(_pos: Vector2) -> void:
	pass


func _on_drag_moved(_pos: Vector2) -> void:
	direction = self.global_position - origin_position

	if direction.length() > max_distance:
		direction = direction.normalized() * max_distance

	self.global_position = origin_position + direction
	rotation = direction.angle() + deg_to_rad(-90)

	update_trajectory_line()


func _on_drag_ended(_result: AreaDragHandler.DragResult) -> void:
	self.global_position = origin_position
	rotation = 0.0

	if direction.length() >= 20.0:
		var instance = obj.instantiate()
		instance.shoot(direction, RNG.rng_array[RNG.current_index])
		get_parent().add_child(instance)

	if RNG.current_index >= 5:
		RNG.stop()
	elif RNG.current_index < RNG.rng_array.size():
		RNG.current_index += 1
		RNG.show_sprite_for_number(RNG.rng_array[RNG.current_index])

	guideline.clear_points()


func update_trajectory_line():
	if not guideline:
		return

	var points: Array = []
	var steps := 12
	var step_time := 0.1  
	var grav := 980
	var velocity := -direction * 12 # Adjust force scale as needed
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
