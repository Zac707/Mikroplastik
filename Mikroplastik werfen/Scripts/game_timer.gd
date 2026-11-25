extends Timer

@export var score: LocalScore

func _on_timeout() -> void:
	score.players_finished = get_parent()._player_total
	if get_parent().has_method("_check_score"):
		get_parent()._check_score(score.score)
	else:
		printerr("Parent of minigame timer has no _check_score method")
	
	if get_parent().has_method("_end_minigame"):
		get_parent()._end_minigame(score.players_finished, score.score)
	else:
		printerr("Parent of minigame timer has no _end_minigame method")
