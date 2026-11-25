extends Node2D
## An example of how to connect a minigame with the logic starting and
## stopping minigames using Zacs slingshot game.

@export var base_win_score: int = 1
@export var slingshots: Array[Node2D]
@export var score_manager: LocalScore
@export var obstacle_timer_right: Timer
@export var obstacle_timer_left: Timer
@export var timer: Timer

var _good_score: int 
var _mid_score: int
var _bad_score: int

var _game_setup: BaseMinigameSetup
var _modifiers: ObjectMinigameModifiers
var _player_total: int:
	set (value):
		push_warning("Slingshot: Setting _player_total from {0} to {1}. "\
			.format([_player_total, value]) + \
			"This is a warning so we get a stack trace.")
		_player_total = value


## ATTENTION: NECESSARY
## This gets called by the MinigameManager through the MinigameSetup.
## Has to have these exact properties.
func setup(player_nr: int, m_setup: BaseMinigameSetup, modifiers: ObjectMinigameModifiers) -> void:
	_game_setup = m_setup
	_modifiers = modifiers
	_player_total = player_nr
	
	# wichtig für die Zuweisung der Sterne
	_good_score = _player_total * 4
	_mid_score = _player_total * 2
	_bad_score = 0
	
	score_manager.player_count_changed.connect(_end_minigame)
	
	_setup_for_player_nr(player_nr)
	_setup_for_decay(_modifiers.decay_level)


## This example just prepares the corresponding number of slingshots based
## on the given player number.
## It does not adjust difficulty.
func _setup_for_player_nr(player_nr: int) -> void:
	for i in slingshots.size():
		if i+1 <= player_nr:
			slingshots[i].visible = true
			slingshots[i].process_mode = Node.PROCESS_MODE_INHERIT
		else:
			slingshots[i].visible = false
			slingshots[i].process_mode = Node.PROCESS_MODE_DISABLED


## This example script just increased the score needed to win based
## on the given object decay level.
## Genuine difficulty adjustments would be stuff like:
## - smaller trashcans
## - more/faster/bigger obstacles
## - higher projectile speed
func _setup_for_decay(decay: Enums.Decay) ->  void:
	if decay == 0:
		obstacle_timer_right.wait_time = 8
		obstacle_timer_left.wait_time = 14
		timer.wait_time = 60
	elif decay < 2:
		_good_score += 2
		_mid_score += 1
		obstacle_timer_right.wait_time = 7
		obstacle_timer_left.wait_time = 12
		timer.wait_time = 50
	else:
		_good_score += 5
		_mid_score += 3
		obstacle_timer_right.wait_time = 6
		obstacle_timer_left.wait_time = 11
		timer.wait_time = 40
	
	timer.start()

# Es kann gut sein dass das Spiel gefühlt verspätet beendet. Das liegt daran, 
# dass die Spieleranzahl im ScoreManager direkt nach dem Wurf angepasst werden 
# würde, ohne abzuwarten wie der letzte Ball fliegt.
# Um ein Puffer zu erschaffen habe ich einen Timer von 5 Sekunden eingestellt.
func _end_minigame(_players_finished, _end_score):
	if _players_finished != _player_total:
		return

	# Hier müsste dein Code kommen der das mit der Architektur verbindet
	push_warning("Players_finished: ", _players_finished, " Spieleranzahl: ", _player_total)
	var score := 1
	if _end_score >= _good_score:
		print("3 Sterne")
		score = 3
	elif _end_score < _good_score and _end_score >= _mid_score:
		print("2 Sterne")
		score = 2
	
	assert(_game_setup, "Minigame root had no BaseMinigameSetup resource when checking score")
	
	# ATTENTION: NECESSARY
	# Calling the finish method gives execution back over to the MinigameManager.
	# The Result Panel will be shown with the given score and the minigame scene will be paused.
	# The score is out of 5 and should be calculated out of the players 
	# performance in the minigame somehow.
	var data = MinigameResultData.new(score)
	_game_setup.finish(data)
