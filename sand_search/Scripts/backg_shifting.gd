extends Sprite2D

@export var center : Vector2
@export var lupe : Area2D

var plastic_loaded = false

func _ready() -> void:
	global_position = center

func _process(_delta: float) -> void:
	if lupe and plastic_loaded == true:
		# Calculate offset from center to lupe position
		var glass_offset = lupe.global_position - center
		# Move sprite opposite to the offset
		global_position = center - (glass_offset * 2)
	
