extends Timer

@export var score_manager: LocalScore


func _on_timeout() -> void:
	score_manager.players_finished = get_parent()._player_total
	get_parent()._end_minigame(score_manager.players_finished, score_manager.score)
