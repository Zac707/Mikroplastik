extends Area2D


@export var _touch_area: Area2D
@export var _also_check_mouse_input: bool
@export var List: Control
@export var Background: Sprite2D
@export var Foreground: Sprite2D
@export var score_manager: LocalScore

var _drag_handler: AreaDragHandler
var collision_detected = false
var collision_box : Area2D


func _ready() -> void:
	_drag_handler = AreaDragHandler.new()
	_drag_handler.setup(_touch_area, self, _also_check_mouse_input)
	_drag_handler.drag_started.connect(_on_drag_started)
	_drag_handler.drag_moved.connect(_on_drag_moved)
	_drag_handler.drag_ended.connect(_on_drag_ended)


func _input(event: InputEvent) -> void:
	_drag_handler.handle_input(event)


func _on_drag_started(_pos: Vector2) -> void:
	pass


func _on_drag_moved(_pos: Vector2) -> void:
	pass


func _on_drag_ended(_result: AreaDragHandler.DragResult) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Lupe"):
		collision_box = area
		collision_detected = true


func _physics_process(delta: float) -> void:
	if collision_detected:
		var dir = global_position - collision_box.global_position
		if dir.length() == 0:
			dir = Vector2(randf() - 0.5, randf() - 0.5).normalized()
		global_position += dir.normalized() * 5 * delta * 60


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Lupe"):
		collision_detected = false
		collision_box = null 
