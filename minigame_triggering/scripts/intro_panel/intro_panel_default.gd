class_name IntroPanelDefault
extends Control

@export_group("Refs")
@export var player_nr_group: SelectButtonGroup
@export var title_label: Label
@export var info_label: Label
@export var start_button: Button

@export_group("Config")
## Wether the text elements of this intro panel should use the text data from
## the MinigameSetup resource or keep the text from the scene.
@export var use_minigame_setup_text: bool = true


var _current_minigame: BaseMinigameSetup
var _current_start_call: Callable


func setup(
	minigame: BaseMinigameSetup, 
	modifiers: ObjectMinigameModifiers, 
	start_clicked: Callable
) -> void:
	_current_minigame = minigame
	_current_start_call = start_clicked
	_setup_labels(minigame)
	player_nr_group.set_min_selected(modifiers.player_amount)
	
	start_button.pressed.connect(_start_minigame)


func _setup_labels(minigame: BaseMinigameSetup) -> void:
	if !use_minigame_setup_text:
		return
	
	title_label.text = minigame.title
	info_label.text = minigame.intro_description


func _start_minigame() -> void:
	if (_current_start_call == null):
		push_error("Intro panel did not have the start method to call")
		return
	_current_start_call.call(player_nr_group.current_selected)
	self.queue_free()
