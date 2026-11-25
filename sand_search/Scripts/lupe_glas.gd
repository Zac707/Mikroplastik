extends Sprite2D

@export var center: Vector2
@export var background: Sprite2D
@export var foreground: Sprite2D

var original_positions: Dictionary = {}


func manual_init():
	for child in get_children():
		if child.is_in_group("Plastic_sand"):
			original_positions[child] = child.global_position


func _process(_delta: float) -> void:
	if background:
		var base_position = background.global_position
		
		for child in get_children():
			if child.is_in_group("Plastic_sand") and child in original_positions:
				# Add the original position as an offset to the calculated position
				child.global_position = base_position + original_positions[child]
		
		background.plastic_loaded = true
		foreground.plastic_loaded = true
