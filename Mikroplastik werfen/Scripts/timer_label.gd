extends Label

@export var timer : Timer

func _process(_delta: float) -> void:
	text = "Time: " + str(int(timer.time_left))  # initial score
