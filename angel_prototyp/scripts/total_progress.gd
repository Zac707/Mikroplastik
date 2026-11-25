class_name TotalProgress
extends Control


signal progress_goal_reached

static var instance: TotalProgress

@export_group("Config")
@export var _tween_duration: float = 1.0
@export var _events: Array[ProgressEvent] = []

@export_group("Refs")
@export var _bar: ProgressBar
@export var _object_spawner: GridObjectSpawner

@export var add_3: bool:
	set (value):
		if value:
			add_progress(3)

var _current_progress: int = 0:
	set (value):
		_current_progress = value
		_tween_bar(_current_progress)

var _tween: Tween


func _init() -> void:
	instance = self


func _ready() -> void:
	_bar.max_value = GlobalConfig.total_progress_goal
	_bar.value = _current_progress
	
	_setup_events()


## Adds an amount to the current progress.
## Has to be a positive value; negative values are clamped.
func add_progress(amount: int) -> void:
	# Do not add progress or call events when max is already reached
	if _current_progress >= GlobalConfig.total_progress_goal:
		return
	
	amount = clampi(amount, 0, GlobalConfig.total_progress_goal - _current_progress)
	_current_progress += amount
	print("Total Progress: adding [%s]" % amount)
	
	_check_events_to_execute()
	
	if _current_progress < GlobalConfig.total_progress_goal:
		return
	
	print("---- GAME WON ----")
	print("---- Progress goal reached ----")
	# TODO: Some kind of UI / Animation
	progress_goal_reached.emit()


## Removes an amount from the current progress.
## Has to be a positive value; negative values are clamped.
func remove_progress(amount: int) -> void:
	amount = clampi(amount, 0, _current_progress)
	_current_progress -= amount


func _setup_events() -> void:
	if _events.is_empty():
		return
	
	for event in _events:
		var icon := event.icon.instantiate() as Control
		var x_pos := _bar.size.x / 2
		var y_pos := _bar.size.y * event.at_percentage
		_bar.add_child(icon)
		icon.position = Vector2(x_pos, y_pos)


func _check_events_to_execute() -> void:
	var percent: float = _current_progress / float(GlobalConfig.total_progress_goal)
	
	for event in _events:
		if percent < event.at_percentage:
			continue
		
		if event is ProgressCleanEvent:
			var params := ProgressCleanEvent.Params.new(_object_spawner)
			event.execute(params)
			print("Executing event! Event: ", event.resource_path)


func _tween_bar(to: int) -> void:
	_tween = _ensure_tween()
	_tween.tween_property(_bar, "value", to, _tween_duration)


func _ensure_tween() -> Tween:
	if _tween && _tween.is_running():
		_tween.kill()
	return create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
