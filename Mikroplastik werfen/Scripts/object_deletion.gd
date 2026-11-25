extends Area2D

@export var score_manager : LocalScore

var balls__caught = 0


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("shoot"):
		balls__caught += 1
	body.queue_free()
	
	if balls__caught == get_parent()._player_total * 6:
		score_manager.players_finished = get_parent()._player_total
		if get_parent().has_method("_end_minigame"):
			get_parent()._end_minigame(score_manager.players_finished, score_manager.score)
