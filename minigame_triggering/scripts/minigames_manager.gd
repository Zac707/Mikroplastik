class_name MinigamesManager
extends Node


signal minigame_set_up
signal minigame_started
signal minigame_ended(results: MinigameResultData)

static var Instance: MinigamesManager

@export_group("Prefabs")
@export var default_intro_panel: PackedScene
@export var default_results_panel: PackedScene

@export_group("Refs")
@export var ui_parent: CanvasLayer
@export var minigame_holder: Node

var current_game: BaseMinigameSetup
var current_modifiers: ObjectMinigameModifiers


func _init() -> void:
	Instance = self


func start_new(minigame: BaseMinigameSetup, modifiers: ObjectMinigameModifiers) -> void:
	# Pause non-minigame core scenes
	print_debug("Starting minigame: " + minigame.resource_name)
	
	# Instantiate and show intro panel
	var intro: IntroPanelDefault
	if minigame.intro_panel_scene != null:
		intro = minigame.intro_panel_scene.instantiate()
	else:
		intro = default_intro_panel.instantiate()
	intro.setup(minigame, modifiers, _start_minigame_clicked)
	ui_parent.add_child(intro)
	
	current_game = minigame
	current_modifiers = modifiers
	current_game.minigame_finished.connect(_minigame_finished)
	minigame_set_up.emit()


## Called by the "Start" Button of the intro panel it is given to
func _start_minigame_clicked(player_nr: int) -> void:
	print_debug("Setting up minigame with " + str(player_nr) + " players")
	var game := current_game.source_scene.instantiate()
	minigame_holder.add_child(game)
	
	current_game.setup(player_nr, game, current_modifiers)
	minigame_started.emit()


func _minigame_finished(results: MinigameResultData) -> void:
	current_game.minigame_finished.disconnect(_minigame_finished)
	
	print_debug("Finished minigame, opening result panel. Score: " + str(results.score))
	
	# Instantiate and show results panel
	var panel: ResultsPanelDefault
	if current_game.results_panel_scene != null:
		panel = current_game.results_panel_scene.instantiate()
	else:
		panel = default_results_panel.instantiate()
	panel.setup.call_deferred(current_game, _confirm_results_clicked, results)
	ui_parent.add_child(panel)
	
	_freeze_minigame_scene.call_deferred()


func _confirm_results_clicked(results: MinigameResultData) -> void:
	print_debug("Closed result panel and ended minigame")
	# Remove minigame scene and UI
	_clear_children(minigame_holder)
	_clear_children(ui_parent)
	minigame_ended.emit(results)
	
	TotalProgress.instance.add_progress(results.score)


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)


func _freeze_minigame_scene() -> void:
	for child in minigame_holder.get_children():
		child.process_mode = Node.PROCESS_MODE_DISABLED
