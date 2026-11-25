class_name CountdownTimerLabel
extends Label


signal timeout


var time_left: float:
	get:
		return _timer.time_left

var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)


func start(time_sec: float) -> void:
	_timer.start(time_sec)


func stop() -> void:
	_timer.stop()


func pause(do_pause: bool) -> void:
	_timer.paused = do_pause


func _time_left() -> Array[int]:
	var minute = floor(_timer.time_left) / 60
	var second = int(_timer.time_left) % 60
	return [minute, second]


func _process(_delta: float) -> void:
	if _timer.paused:
		return
	
	text = "%02d:%02d" % _time_left()


func _on_timeout() -> void:
	timeout.emit()
