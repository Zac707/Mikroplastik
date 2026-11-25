extends Sprite2D

@export var center : Vector2
@export var lupe : PackedScene

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if lupe:
		# Calculate offset from center to lupe position
		var offset = lupe.global_position - center
		# Move sprite opposite to the offset
		global_position = center - (offset * 2)
