extends Area2D

@export var timer : Timer
@export var glas : Sprite2D

var plastic_to_delete


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Plastic_sand_hitbox") and area.get_parent().get_parent() == glas:
		plastic_to_delete = area
		timer.start()


func _on_timer_timeout() -> void:
	get_parent().score_manager.add_points(1)
	plastic_to_delete.removal()


func _on_area_exited(_area: Area2D) -> void:
	timer.stop()
