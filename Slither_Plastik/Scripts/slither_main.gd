extends Node2D
# INFO: Das hier ist aktuell nur ein temporärer placeholder, um das slither
# Minigame überhaupt mit der Minigame Architektur starten zu können.


@export var temp_end_button: Button

var _game_setup: BaseMinigameSetup
var _modifiers: ObjectMinigameModifiers



func setup(player_nr: int, m_setup: BaseMinigameSetup, modifiers: ObjectMinigameModifiers) -> void:
	_game_setup = m_setup
	_modifiers = modifiers
	
	_spawn_worms(player_nr)
	
	# Nur zum testen
	temp_end_button.pressed.connect(_end_minigame)
	temp_end_button.visible = true


func _spawn_worms(count: int) -> void:
	# TODO: Spawn a worm for each player
	for i in count:
		pass


func _end_minigame() -> void:
	var data = MinigameResultData.new(5)
	_game_setup.finish(data)
