class_name FishableObject
extends Node2D


signal attached_nr_changed

@export_group("Config")
@export var minigame: BaseMinigameSetup
@export var decay_level_sprites: Array[Texture]

## The color for this objects microplastic puddle. 
## The puddles alpha is taken from its modulate, not from this.
@export var puddle_color: Color = Color.BURLYWOOD
@export_range(1, 3, 1) var needed_players: int = 1

## This Node2D is intended to simulate how the hook is moved to attach 
## to this object.
## When attaching, the hook will be given this objects position and rotation.
@export var hook_attachment_obj: Node2D


@export_group("Bobbing")
@export var bob_height_min: float = 4.0
@export var bob_height_max: float = 8.0
@export var bob_duration_min: float = 2.5
@export var bob_duration_max: float = 4.5
@export var tilt_angle_min: float = 1.0
@export var tilt_angle_max: float = 4.0

@export_group("Refs")
@export var sprite: Sprite2D
@export var area: Area2D
@export var decay_timer: Timer
@export var puddle_prefab: PackedScene


var current_decay_level: Enums.Decay = Enums.Decay.NONE
var attached_players_count: int = 0

var start_y: float
var start_tilt: float
var bob_tween: Tween
var bob_tilt_tween: Tween

var puddle: PuddleVisual


func _ready() -> void:
	start_y = position.y
	start_tilt = rotation_degrees
	_start_bob()
	
	area.body_entered.connect(_on_body_entered)
	tree_exited.connect(_vanish_puddle)
	
	var decay_time := GlobalConfig.seconds_per_decay_level
	var randomization := GlobalConfig.decay_time_randomization
	var randomized_decay_time := randf_range(
		decay_time - randomization, decay_time + randomization
	)
	decay_timer.wait_time = randomized_decay_time
	decay_timer.timeout.connect(_on_decay_timeout)
	decay_timer.start()
	
	if needed_players < 1:
		printerr("Needed players of fishable object " + name + " is below 1. This can be caused by " + \
			"incorrectly saved default values, reset the value in the inspector.")
		needed_players = 1


## Stops the water bobbing and vanishes the puddle.
## Call when reeling in the object.
func ready_for_reel_in() -> void:
	_vanish_puddle()


func start_minigame() -> void:
	var modifiers = ObjectMinigameModifiers.new(current_decay_level, needed_players)
	MinigamesManager.Instance.start_new(minigame, modifiers)
	queue_free()


func detach() -> void:
	attached_players_count -= 1


func _on_body_entered(body: Node2D) -> void:
	if body is not FishingRB:
		return
	
	var rb = body as FishingRB
	if rb.flying_out || rb.has_attached_object():
		return
	
	rb.attach_object(self, \
		hook_attachment_obj.global_position, hook_attachment_obj.global_rotation)
	attached_players_count += 1
	attached_nr_changed.emit()
	_stop_bob()


func _on_decay_timeout() -> void:
	if current_decay_level >= Enums.Decay.HEAVY:
		return
	
	current_decay_level = (current_decay_level + 1) as Enums.Decay
	if decay_level_sprites.size() > current_decay_level:
		sprite.texture = decay_level_sprites[current_decay_level]
	
	# Manage global pollution and puddle
	PollutionManager.instance.add_pollution(GlobalConfig.decay_lvl_change_pollution)
	_increment_puddle()
	
	decay_timer.start()


func _increment_puddle() -> void:
	if !puddle:
		puddle = puddle_prefab.instantiate() as PuddleVisual
		puddle.global_position = self.global_position
		puddle.modulate = Color(puddle_color, puddle.modulate.a)
		PollutionManager.instance.puddle_container.add_child(puddle)
		puddle.spawn()
	else:
		puddle.expand(2)

func _vanish_puddle() -> void:
	if !puddle:
		return
	puddle.vanish()


#region Water bobbing
func _start_bob():
	if bob_tween and bob_tween.is_running():
		bob_tween.kill()
	if bob_tilt_tween and bob_tilt_tween.is_running():
		bob_tilt_tween.kill()

	bob_tween = create_tween()
	bob_tween.set_loops(3) # nr of loops before randomizing again
	
	bob_tilt_tween = create_tween()
	bob_tilt_tween.set_loops(3)

	# --- Get random values for this round ---
	var bob_height = randf_range(bob_height_min, bob_height_max)
	var bob_duration = randf_range(bob_duration_min, bob_duration_max)
	var tilt_angle = randf_range(tilt_angle_min, tilt_angle_max)

	# --- Vertical Bobbing ---
	bob_tween.tween_property(self, "position:y", 
		start_y - bob_height, bob_duration/2
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tween.tween_property(self, "position:y", 
		start_y + bob_height, bob_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tween.tween_property(self, "position:y", 
		start_y, bob_duration/2
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# --- Tilt ---
	bob_tilt_tween.tween_property(self, "rotation_degrees", 
		start_tilt + tilt_angle, bob_duration/2
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tilt_tween.tween_property(self, "rotation_degrees", 
		start_tilt - tilt_angle, bob_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tilt_tween.tween_property(self, "rotation_degrees", 
		start_tilt, bob_duration/2
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# --- Connect callback to restart ---
	bob_tween.finished.connect(_start_bob)


func _stop_bob() -> void:
	if bob_tween && bob_tween.is_running():
		bob_tween.custom_step(100) # any time greater than the possible max time
		bob_tween.kill()
	if bob_tilt_tween && bob_tilt_tween.is_running():
		bob_tilt_tween.custom_step(100) # any time greater than the possible max time
		bob_tilt_tween.kill()

#endregion


#region Utility
func has_enough_players() -> bool:
	return attached_players_count >= needed_players


## Returns the decimal of how many of the needed players are attached,
## e.g. 0.5 for 1/2 players.
func get_players_ratio() -> float:
	return clampf(float(attached_players_count) / needed_players, 0, 1)

#endregion
