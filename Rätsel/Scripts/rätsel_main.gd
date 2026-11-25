extends Node2D

@export var camera: Camera2D
@export var score_label: Label
@export var time_label: Label
@export var score_manager: LocalScore
@export var timer: Timer

var current_food = 5
var current_plastic: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _game_setup: BaseMinigameSetup
var _modifiers: ObjectMinigameModifiers
var _player_total: int:
	set (value):
		push_warning("Slingshot: Setting _player_total from {0} to {1}. "
			.format(str(_player_total), str(value)) + 
			"This is a warning so we get a stack trace.")
		_player_total = value

var _good_score: int 
var _mid_score: int
var _bad_score: int


func setup(player_nr: int, m_setup: BaseMinigameSetup, modifiers: ObjectMinigameModifiers) -> void:
	_game_setup = m_setup
	_modifiers = modifiers
	_player_total = player_nr
	
	#wichtig für die Zuweisung der Sterne
	_good_score = _player_total * 2
	_mid_score = _player_total * 1
	_bad_score = _player_total
	
	score_manager.player_count_changed.connect(_end_minigame)
	
	_setup_for_player_number(player_nr)
	_setup_for_decay(_modifiers.decay_level)


func _setup_for_player_number(count: int) -> void:
	if count == 1:
		camera.global_position = Vector2(640, 360)
		camera.zoom = Vector2(1, 1)
		timer.wait_time = 120
	
	if count == 2:
		camera.global_position = Vector2(640, 1191)
		camera.zoom = Vector2(0.85, 0.85)
		timer.wait_time = 140
	
	if count == 3:
		camera.global_position = Vector2(640, 2540)
		camera.zoom = Vector2(0.58, 0.58)
		timer.wait_time = 160


func _setup_for_decay(decay: Enums.Decay) ->  void:
	if decay == 0:
		timer.wait_time -=0 
	elif decay < 2:
		_good_score = _player_total * 3
		_mid_score = _player_total * 2
		timer.wait_time -= 20
	else:
		_good_score = _player_total * 4
		_mid_score = _player_total * 2
		timer.wait_time -= 40
	
	timer.start()

func _end_minigame(_players_finished, _end_score):
	if _players_finished == _player_total:
		if _end_score >= _good_score:
			_end_score = 3
		elif _end_score < _good_score and _end_score >= _mid_score:
			_end_score = 2
		else:
			_end_score = 1
		
		score_manager.players_finished = 0
		score_manager.score = 0
		#ScoreManager.score_changed.disconnect(_end_minigame)
		var data = MinigameResultData.new(_end_score)
		_game_setup.finish(data)


func _on_timer_timeout() -> void:
	score_manager.players_finished = _player_total
	var final_score = score_manager.score
	_end_minigame(_player_total, final_score)
