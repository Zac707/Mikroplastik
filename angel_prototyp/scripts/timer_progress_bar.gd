class_name TimerProgressBar
extends ProgressBar


@export var timer: Timer

func _ready() -> void:
	assert(timer)
	timer.timeout.connect(_reset)
	max_value = 1


func _process(_delta: float) -> void:
	if timer.is_stopped() || timer.paused:
		return
	
	var time_progress = timer.wait_time - timer.time_left
	value = time_progress / timer.wait_time


func _reset() -> void:
	value = 0
