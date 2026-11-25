extends Node2D


@export var tilemap: TileMap
@export var food_scene: PackedScene
@export var plastic_scene: PackedScene
@export var min_v: Vector2 = Vector2(0, 0)
@export var max_v: Vector2 = Vector2(15, 8)
@export var max_food_number: float = 5.0
@export var max_plastic_number: float = 5.0
@export var max_spawn_tries: int = 50
@export var camera: Camera2D
@export var score_label: Label
@export var time_label: Label
@export var score_manager: LocalScore
@export var timer: Timer

var current_food: float
var current_plastic: float
var food_addition: float
var plastic_addition: float
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


func _ready():
	rng.randomize()
	current_food = max_food_number
	current_plastic = max_plastic_number


func setup(player_nr: int, m_setup: BaseMinigameSetup, modifiers: ObjectMinigameModifiers) -> void:
	_game_setup = m_setup
	_modifiers = modifiers
	_player_total = player_nr
	
	#wichtig für die Zuweisung der Sterne
	_good_score = _player_total * 5
	_mid_score = _player_total * 3
	_bad_score = _player_total
	
	score_manager.player_count_changed.connect(_end_minigame)
	
	_spawn_worms(player_nr)
	_setup_for_decay(_modifiers.decay_level)


func _spawn_worms(count: int) -> void:
	if count == 1:
		camera.global_position = Vector2(640, 360)
		camera.zoom = Vector2(1, 1)
		min_v = Vector2(0, 0)
		max_v = Vector2(15, 8)
	
	if count == 2:
		camera.global_position = Vector2(800, 1360)
		camera.zoom = Vector2(0.75, 0.75) 
		min_v = Vector2(-1, 11)
		max_v = Vector2(20, 22)
	
	if count == 3:
		camera.global_position = Vector2(1000, 2720)
		camera.zoom = Vector2(0.64, 0.64)
		min_v = Vector2(0, 26)
		max_v = Vector2(24, 41)


func _setup_for_decay(decay: Enums.Decay) ->  void:
	if decay == 0:
		timer.wait_time = 35
		food_addition = 0.7
		plastic_addition = 1.5
	elif decay < 2:
		_good_score += 4
		_mid_score += 2
		timer.wait_time = 30
		food_addition = 1.0
		plastic_addition = 1.0
	else:
		_good_score += 8
		_mid_score += 4
		timer.wait_time = 25
		food_addition = 1.5
		plastic_addition = 0.7
	
	timer.start()


func _end_minigame(_players_finished, _end_score):
	if _players_finished == _player_total:
		# Hier müsste dein Code kommen der das mit der Architektur verbindet
		print("Worm: Players_finished: ", _players_finished, " Spieleranzahl: ", _player_total)
		if _end_score >= _good_score:
			_end_score = 3
		elif _end_score < _good_score and _end_score >= _mid_score:
			_end_score = 2
		else:
			_end_score = 1
		
		assert(_game_setup, "Minigame root had no BaseMinigameSetup resource when checking score")
		score_manager.players_finished = 0
		score_manager.score = 0
		#ScoreManager.score_changed.disconnect(_end_minigame)
		var data = MinigameResultData.new(_end_score)
		_game_setup.finish(data)


func spawn_food_in_visible_area():
	var attempts = 0
	var placed = false
	
	while attempts < max_spawn_tries and not placed:
		var ran_placing = Vector2i(
			rng.randi_range(int(min_v.x), int(max_v.x)),
			rng.randi_range(int(min_v.y), int(max_v.y))
		)
		
		# Check if cell is empty
		var existing_cell = tilemap.get_cell_source_id(0, ran_placing)
		if existing_cell == -1:  # Cell is empty
			# Convert tile position to world position
			var world_pos = tilemap.map_to_local(ran_placing)
			
			# Instantiate and add the food scene
			var food_instance = food_scene.instantiate()
			food_instance.position = world_pos
			add_child(food_instance)
			
			current_food += food_addition
			placed = true
		
		attempts += 1
	
	if not placed:
		print("Failed to spawn food after ", max_spawn_tries, " attempts")


func spawn_plastic_in_visible_area():
	var attempts = 0
	var placed = false
	
	while attempts < max_spawn_tries and not placed:
		var ran_placing = Vector2i(
			rng.randi_range(int(min_v.x), int(max_v.x)),
			rng.randi_range(int(min_v.y), int(max_v.y))
		)
		
		# Check if cell is empty
		var existing_cell = tilemap.get_cell_source_id(0, ran_placing)
		if existing_cell == -1:  # Cell is empty
			# Convert tile position to world position
			var world_pos = tilemap.map_to_local(ran_placing)
			
			# Instantiate and add the food scene
			var plastic_instance = plastic_scene.instantiate()
			plastic_instance.position = world_pos
			add_child(plastic_instance)
			
			current_plastic += plastic_addition
			placed = true
		
		attempts += 1
	
	if not placed:
		print("Failed to spawn food after ", max_spawn_tries, " attempts")


func _on_timer_timeout() -> void:
	if current_food < max_food_number:
		spawn_food_in_visible_area()
	if current_plastic < max_plastic_number:
		spawn_plastic_in_visible_area()
