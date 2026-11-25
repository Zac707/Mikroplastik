extends Area2D

@export var score_manager: LocalScore


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Line_Rätsel"):
		var pos = self.global_position
		area.create_new_point(pos)
		area.control_area._drag_handler = null
		score_manager.add_points(area.points_earned)
		score_manager.check_player_count(1)
