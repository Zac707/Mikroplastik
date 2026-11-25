class_name SelectButtonGroup
extends HBoxContainer

const START_FIRST_SELECTED: bool = true


@export var unselected_tex: Texture2D
@export var selected_tex: Texture2D

var current_selected: int = 0

var _buttons: Array[TextureButton]
var _min_selected: int

func _ready() -> void:
	_get_buttons()
	
	if _buttons.size() < 2:
		push_error("Button group had less than 2 children on _ready")
		return;
	
	_prepare_buttons()


func set_min_selected(minimum: int) -> void:
	_select_button.call_deferred(max(0, minimum - 1))
	_min_selected = minimum


func _get_buttons() -> void:
	for node in get_children():
		if node is not TextureButton:
			push_error("Button group has a non-TextureButton child: " + node.name)
			continue
		_buttons.append(node as TextureButton)


func _prepare_buttons() -> void:
	print_debug("Setting up button group. This should only be called once.")
	# Check setup
	if START_FIRST_SELECTED:
		current_selected = 1
		_buttons[0].texture_normal = selected_tex
	else:
		current_selected = 0
		_buttons[0].texture_normal = unselected_tex
	
	# Connect the pressed functions
	for i in _buttons.size():
		var lambda := func() -> void:
			_select_button(i)
		_buttons[i].pressed.connect(lambda)


func _select_button(index: int) -> void:
	if index < 0 || index >= _buttons.size():
		push_error("Selected button index out of bounds (" + str(index) + ")")
		return;
	
	if index < _min_selected - 1:
		index = _min_selected - 1
	
	var selected_nr := 0
	
	for i in _buttons.size():
		if i <= index:
			selected_nr += 1
			_buttons[i].texture_normal = selected_tex
		else:
			_buttons[i].texture_normal = unselected_tex
	
	current_selected = selected_nr
