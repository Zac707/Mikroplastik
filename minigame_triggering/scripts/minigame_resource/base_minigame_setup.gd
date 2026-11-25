class_name BaseMinigameSetup
extends Resource
## Base class to extend for implementing Minigame Setups
##
## Contains all data and methods for setting up and managing the ending
## of a minigame. 
## Extend this and override the necessary methods to create the actual setup.


## Emitted by the minigame when it ends.
## Subscribed to by the MinigameManager.
signal minigame_finished(results: MinigameResultData)


## The 2D main scene of the minigame itself.
@export var source_scene: PackedScene

## The Control (UI) scene of this minigames version of the Intro Panel.
## If this is empty, the default in the MinigamesManager will be used instead.
@export var intro_panel_scene: PackedScene
@export var title: String
@export_multiline var intro_description: String

## The Control (UI) scene of this minigames version of the Results Panel.
## If this is empty, the default in the MinigamesManager will be used instead.
@export var results_panel_scene: PackedScene
@export var plastic_facts: Array[String]


func setup(player_nr: int, game_root: Node, modifiers: ObjectMinigameModifiers) -> void:
	assert(game_root.has_method("setup"), \
		"Minigame root node " + game_root.name + " has no setup function")
	
	assert(game_root.get_method_argument_count("setup") == 3, \
		"Minigame root node " + game_root.name + " has setup function with wrong argument count")
	
	game_root.call("setup", player_nr, self, modifiers)


func finish(results: MinigameResultData) -> void:
	minigame_finished.emit(results)
