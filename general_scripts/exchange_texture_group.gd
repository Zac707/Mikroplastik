class_name ExchangeTextureGroup
extends HBoxContainer
## Exchanges the textures of a group of TextureRects between an inactive
## and active texture.
##
## Meant for showing the score through stars.
## I.e. the active texture is a filled star, the inactive texture a not filled one.


@export var active_tex: Texture2D
@export var inactive_tex: Texture2D


var group_size: int


func _ready() -> void:
	assert(active_tex)
	assert(inactive_tex)
	group_size = get_child_count()


## Set the given number of TextureRects to their active textures.
## Expected use example: Player scored 2/3. Call this with number = 2.
## The first 2 of 3 stars are set to their filled textures.
func activate_up_to(number: int) -> void:
	assert(number <= group_size)
	assert(number > 0)
	
	var rects := _get_tex_children()
	for i in rects.size():
		if (i + 1) <= number:
			rects[i].texture = active_tex
		else:
			rects[i].texture = inactive_tex


func _get_tex_children() -> Array[TextureRect]:
	var rects: Array[TextureRect]
	for child in get_children():
		if child is not TextureRect:
			push_error("Has a child that is not a TextureRect")
			continue
		rects.append(child)
	
	return rects
