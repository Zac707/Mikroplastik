class_name MultiTouchButton
extends Button
## A simple button that emits signals for both mouse and multi-touch input.
##
## Covers all normal button signals


func _gui_input(event: InputEvent) -> void:
	var event_pos_adjusted: Vector2 = event.position + global_position
	var inside: bool = (
		event_pos_adjusted.x > position.x and 
		event_pos_adjusted.y > position.y and 
		event_pos_adjusted.x < position.x + size.x and 
		event_pos_adjusted.y < position.y + size.y)
	
	if event is InputEventScreenTouch and event.pressed and inside:
		if toggle_mode:
			toggled.emit()
			button_pressed = true
		else:
			pressed.emit()
			button_down.emit()
		
	elif (event is InputEventScreenTouch and inside) or \
	(event is InputEventScreenTouch and !event.pressed and !inside):
		button_up.emit()
		button_pressed = false
