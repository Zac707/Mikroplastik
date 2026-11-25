extends Timer

@export var score_manager: LocalScore


func _on_timeout() -> void:
	if get_parent().has_method("_end_minigame"):
		get_parent().time_over = true
		get_parent()._end_minigame(score_manager.score)
	else:
		printerr("Parent of minigame timer has no _end_minigame method")
