extends Area2D

var plastic_count = 0
var max_speed = 200
var food_count = 0

@export var ground: Area2D
@export var worm: Line2D


func _ready() -> void:
	self.position = worm.points[0]
	if worm.Ground_Texture:
		var ground_instance = worm.Ground_Texture.instantiate()
		ground_instance.position = self.position
		worm.Ground.add_child(ground_instance)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Wall_Worm"):
		worm.score_manager.check_player_count(1)
		ground.reparent.call_deferred(worm.root)
		worm.queue_free.call_deferred()

	if area.is_in_group("Plastic_Worm"):
		area.queue_free()
		plastic_count += 1
		worm.speed -= 20
		worm.get_parent().current_plastic -= 1
		worm.score_manager.add_points(-1)
		if plastic_count == 5:
			worm.queue_free()

	if area.is_in_group("Food_Worm"):
		area.queue_free()
		food_count += 1
		worm.get_parent().current_food -= 1
		worm.score_manager.add_points(1)
		if food_count % 2 == 0 and plastic_count > 0:
			plastic_count -= 1
		if worm.speed < max_speed:
			worm.speed += 5


func _on_area_exited(area: Area2D) -> void:
	# Only create ground when leaving specific area types
	if area.is_in_group("Worked_Ground"):
		if worm.Ground_Texture and worm.Ground:
			var ground_instance = worm.Ground_Texture.instantiate()
			ground_instance.position = self.position
			ground_instance.rotation = worm.Textures[0].rotation
			worm.Ground.add_child.call_deferred(ground_instance)
