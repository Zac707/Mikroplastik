extends PathFollow2D

@export var speed : float
var direction = 1

func _process(delta: float):
	progress_ratio += delta * speed * direction
	
	if progress_ratio >= 1:
		progress_ratio = 1
		direction = -1
	elif progress_ratio <= 0:
		progress_ratio = 0
		direction = 1
