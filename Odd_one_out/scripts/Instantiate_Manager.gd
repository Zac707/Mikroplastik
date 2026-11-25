extends Node2D

@export_group("Level Settings")
@export var level: OddOneOutLevel

@export_group("Prefabs")
@export var fruits: Array[PackedScene]
@export var plastic: Array[PackedScene]

@export_group("Refs")
@export var object_container: Node2D
@export var point_label: Label
@export var countdown: CountdownTimerLabel

@export_group("Config")
@export var min_points: int = 5

var window_size: Vector2i

var point_counter: int = 0

var _game_setup: BaseMinigameSetup
var _modifiers: ObjectMinigameModifiers

var _plastics_count: int
var _collected_plastics: int
var _win_points: int


# Die aktuelle Berechnung von _win_points, _plastics_count und dem score,
# mit dem das Minigame beendet wird, sind rein provisorisch

func _ready():
	window_size = get_viewport().size


func _on_button_test_start() -> void:
	_plastics_count = 3
	_win_points = min_points +5
	countdown.start(120)
	countdown.timeout.connect(_end_minigame)
	_spawn_all()


func setup(player_nr: int, m_setup: BaseMinigameSetup, modifiers: ObjectMinigameModifiers) -> void:
	_game_setup = m_setup
	_modifiers = modifiers
	
	_plastics_count = player_nr
	_win_points = int(min_points * (1 + int(modifiers.decay_level) / 2.0) * player_nr)
	
	countdown.start(120)
	countdown.timeout.connect(_end_minigame)
	_spawn_all()


func _spawn_all():
	_spawn_fruits(level.bio_obj_count)
	_spawn_plastics(_plastics_count)
	

func _spawn_fruits(count: int) -> void:
	for i in count:
		var fruit_obj = fruits.pick_random().instantiate() as BioMüllMovement
		fruit_obj.setup(level.bio_speed)
		fruit_obj.position = _get_random_pos()
		object_container.add_child(fruit_obj)


func _spawn_plastics(count: int) -> void:
	_collected_plastics = 0
	for i in count:
		var plastic_obj = plastic.pick_random().instantiate() as PlastikMüllMovement
		plastic_obj.setup(level.plastic_speed)
		plastic_obj.position = _get_random_pos()
		object_container.add_child(plastic_obj)
		
		plastic_obj.clicked.connect(_on_plastic_clicked)


func _get_random_pos() -> Vector2i:
	var x_pos := randi_range(1, window_size.x)
	var y_pos := randi_range(1, window_size.y)
	return Vector2i(x_pos, y_pos)


func _on_plastic_clicked() -> void:
	_increment_score()
	_collected_plastics += 1
	
	if _collected_plastics >= _plastics_count:
		_respawn_objects()


func _increment_score() -> void:
	point_counter += 1
	point_label.text = "Punkte: " + str(point_counter) + "/" + str(_win_points)
	
	if point_counter >= _win_points:
		_end_minigame()


func _respawn_objects()-> void:
	for child in object_container.get_children():
		child.queue_free()
	_spawn_all()


func _end_minigame() -> void:
	var data = MinigameResultData.new(2)
	# Give a higher score if more than 20 seconds are left
	if countdown.time_left > 20:
		data.score = 3
	_game_setup.finish(data)
