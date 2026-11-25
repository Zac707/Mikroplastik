class_name MainSceneController
extends Node

@export var minigames_manager: MinigamesManager
@export var fishing_scene: Node2D
@export var test_ui: CanvasLayer
@export var state_ui: CanvasLayer
@export var _game_over_ui_prefab: PackedScene
@export var _game_won_ui_prefab: PackedScene


func _ready() -> void:
	assert(minigames_manager)
	assert(fishing_scene)
	assert(test_ui)
	assert(state_ui)
	
	minigames_manager.minigame_set_up.connect(_on_freeze_requested)
	minigames_manager.minigame_ended.connect(_on_minigame_ended)
	
	TotalProgress.instance.progress_goal_reached.connect(_on_game_won)
	PollutionManager.instance.max_pollution_reached.connect(_on_game_over)
	GridObjectSpawner.instance.grid_filled.connect(_on_game_over)


func _on_freeze_requested() -> void:
	_freeze_fishing_scene.call_deferred(true)


func _on_minigame_ended(_results: MinigameResultData) -> void:
	_freeze_fishing_scene(false)


func _freeze_fishing_scene(freeze: bool) -> void:
	if freeze:
		fishing_scene.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		fishing_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	fishing_scene.visible = !freeze
	
	test_ui.visible = !freeze


func _on_game_won() -> void:
	_freeze_fishing_scene.call_deferred(true)
	var ui := _game_won_ui_prefab.instantiate() as GameWonUI
	ui.setup(_on_restart_pressed)
	add_child(ui)


func _on_game_over() -> void:
	_freeze_fishing_scene.call_deferred(true)
	var ui := _game_over_ui_prefab.instantiate() as GameOverUI
	ui.setup(_on_restart_pressed)
	add_child(ui)


## Delegate given to the Game Over and Game Won UIs
func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()



# --- No longer used but nice info: ---

# This function sets the process_mode of all nodes in the [member core_scenes]
# list to DISABLED, except for the given node.
# Also makes  these nodes invisible if they are a Node2D (base Nodes do not
# inherit from CanvasItem and cannot be made invisible)
# Logs an error if the given node is not in [member core_scenes].
# This does NOT pause the whole game, just the core_scenes.
# For this to work, the process_mode of all their child nodes has to be INHERIT.
#func disable_all_except_this(root: Node) -> void:
	#if !core_scenes.has(root):
		#push_error("Tried to pause the rest of the game for a non-core scene " +\
			#"(" + root.name + ")")
		#return
	#
	#for scene in core_scenes:
		#scene.process_mode = Node.PROCESS_MODE_DISABLED
		#if scene is Node2D:
			#scene.visible = false
	#
	#root.process_mode = Node.PROCESS_MODE_PAUSABLE
	#if root is Node2D:
		#root.visible = true
