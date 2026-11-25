extends Node2D

var _game_setup: BaseMinigameSetup
var _modifiers: ObjectMinigameModifiers
var _player_total
var _good_score
var _mid_score
var _bad_score
var total_points: int
var time_over = false

@export var magnifying_glasses : Array[Node2D]
@export var List : Control
@export var Camera : Camera2D
@export var Timer_Label : Label
@export var score_manager: LocalScore
@export var timer: Timer


func setup(player_nr: int, m_setup: BaseMinigameSetup, modifiers: ObjectMinigameModifiers) -> void:
	_game_setup = m_setup
	_modifiers = modifiers
	_player_total = player_nr
	
	# wichtig für die Zuweisung der Sterne
	_good_score = _player_total * 3
	_mid_score = _player_total * 2
	_bad_score = 0
	
	score_manager.score_changed.connect(_end_minigame)
	
	_setup_for_decay(_modifiers.decay_level)
	_setup_for_player_nr(player_nr)


func _setup_for_player_nr(player_count):
	for i in magnifying_glasses.size():
		if i+1 <= player_count:
			magnifying_glasses[i].visible = true
			magnifying_glasses[i].process_mode = Node.PROCESS_MODE_INHERIT
		else:
			magnifying_glasses[i].visible = false
			magnifying_glasses[i].process_mode = Node.PROCESS_MODE_DISABLED
	
	if player_count == 1:
		List.x_range = 590
		List.y_range = 310
		Camera.zoom = Vector2(1, 1)
		List.sample_dictionary = {"Plastik 1" :  1, "Plastik 2" : 1, "Plastik 3" : 1}
		for glass in magnifying_glasses:
			glass.Background.scale = Vector2(3, 3)
			glass.Foreground.scale = Vector2(3, 3)
	
	elif player_count == 2:
		List.x_range = 790
		List.y_range = 420
		Camera.zoom = Vector2(0.9, 0.9)
		List.sample_dictionary = {"Plastik 1" :  2, "Plastik 2" : 2, "Plastik 3" : 2}
		for glass in magnifying_glasses:
			glass.Background.scale = Vector2(4, 4)
			glass.Foreground.scale = Vector2(4, 4)
	
	else:
		List.x_range = 990
		List.y_range = 530
		Camera.zoom = Vector2(0.8, 0.8)
		List.sample_dictionary = {"Plastik 1" :  3, "Plastik 2" : 3, "Plastik 3" : 3}
		for glass in magnifying_glasses:
			glass.Background.scale = Vector2(5, 5)
			glass.Background.scale = Vector2(5, 5)
	
	List.manual_init()
	
	for value in GlobalList.dic.values():
		total_points += value
	print(total_points)
	# score_manager.add_points(total_points)
	# Codezeile von einer alten Funktionsweise wo ich von der maxpunktzahl rubnter auf 0 gerrechnet habe


func _setup_for_decay(decay: Enums.Decay) ->  void:
	if decay == 0:
		timer.wait_time = 60
	elif decay < 2:
		timer.wait_time = 50
		for i in magnifying_glasses:
			i.Foreground.visible = true
	else:
		timer.wait_time = 40
		for i in magnifying_glasses:
			i.Foreground.visible = true
	
	timer.start()
	timer.timeout.connect(func() -> void:
		time_over = true
		_end_minigame(score_manager.score))


func _end_minigame(_end_score):
	print("Sandseach end score:", _end_score)
	if _end_score == _player_total * 3 or time_over == true:
		if _end_score >= _good_score:
			_end_score = 3
		elif _end_score < _good_score and _end_score >= _mid_score:
			_end_score = 2
		else:
			_end_score = 1
		
		assert(_game_setup, "Minigame root had no BaseMinigameSetup resource when checking score")
		score_manager.players_finished = 0
		score_manager.score = 0
		time_over = false
		
		var data = MinigameResultData.new(_end_score)
		_game_setup.finish(data)
