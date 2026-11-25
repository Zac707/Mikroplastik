extends Node2D
@export var PP : Sprite2D
@export var PE : Sprite2D
@export var PET : Sprite2D
@export var Hitbox : Area2D
@export var guideline : Line2D
@export var timer: Timer
@export var score: LocalScore

var rng_array = []
var current_index = 0

func _ready():
	randomize() # Make sure to call this once before generating random numbers
	rng_array = generate_rng_array()
	show_sprite_for_number(rng_array[current_index])

func generate_rng_array():
	var result = []
	for i in range(6):
		var num =randi() % 3 + 1
		result.append(num)
	return result


func show_sprite_for_number(num: int) -> void:
	if num == 1:
		PP.visible = true
		PE.visible = false
		PET.visible = false
		guideline.modulate = Color(0.324, 0.581, 0.922)
		
	if num == 2:
		PP.visible = false
		PE.visible = true
		PET.visible = false
		guideline.modulate = Color(0.913, 0.566, 0.767)
		
	if num == 3:
		PP.visible = false
		PE.visible = false
		PET.visible = true
		guideline.modulate = Color(0.349, 0.876, 0.302)
	

func stop():
	PP.visible = false
	PE.visible = false
	PET.visible = false
	Hitbox.input_pickable = false
	timer.start()


func _on_timer_timeout() -> void:
	score.check_player_count(1)
