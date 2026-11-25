extends Label

func _ready() -> void:
	text = str(get_parent().id_pair)
