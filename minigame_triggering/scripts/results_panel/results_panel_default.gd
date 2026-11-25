class_name ResultsPanelDefault
extends Control


@export_group("Refs")
@export var score_group: ExchangeTextureGroup
@export var title_label: Label
@export var info_label: Label
@export var confirm_button: Button
@export var highlight: TextureRect

@export_group("Config")
## Wether the text elements of this results panel should use the text data from
## the MinigameSetup resource or keep the text from the scene.
@export var use_minigame_setup_text: bool = true


var _current_minigame: BaseMinigameSetup
var _current_close_call: Callable
var _results: MinigameResultData


func setup(minigame: BaseMinigameSetup, confirm_clicked: Callable, results: MinigameResultData) -> void:
	_current_minigame = minigame
	_current_close_call = confirm_clicked
	_results = results
	_setup_UI(minigame)
	
	confirm_button.pressed.connect(_finish)


func _setup_UI(minigame: BaseMinigameSetup) -> void:
	if !use_minigame_setup_text:
		return
	
	title_label.text = minigame.title
	if minigame.plastic_facts.size() > 0:
		info_label.text = minigame.plastic_facts.pick_random()
	
	score_group.activate_up_to(_results.score)


func _finish() -> void:
	if (_current_close_call == null):
		push_error("Results panel did not have the close method to call")
		return
	_current_close_call.call(_results)
	self.queue_free()
