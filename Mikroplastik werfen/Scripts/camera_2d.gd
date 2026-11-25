extends Camera2D

func _ready() -> void:
	var zoom_level = Vector2(1.2, 1.2)
	self.set_zoom(zoom_level)
