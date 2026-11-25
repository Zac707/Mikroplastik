extends Node2D

@export var lupe: Area2D
@export var Plastic_1: PackedScene
@export var Plastic_2: PackedScene
@export var Plastic_3: PackedScene
@export var spawn_position: Vector2 = Vector2.ZERO
@export var spacing_between_objects: float = 50.0
@export var second_background: Sprite2D

var received_dictionary: Dictionary = {}
var pos_x
var pos_y
var spawned_objects: Array[Node] = []
var id: int = 1


func _ready() -> void:
	lupe.List.dictionary_data_sent.connect(_on_dictionary_received)


func _on_dictionary_received(dict: Dictionary, position_x: Array, position_y: Array) -> void:
	received_dictionary = dict.duplicate()
	pos_x = position_x.duplicate()
	pos_y = position_y.duplicate()
	# Clear previous objects
	for obj in spawned_objects:
		obj.queue_free()
	spawned_objects.clear()
	
	for key in received_dictionary.keys():
		var count = received_dictionary[key]
		var scene_to_spawn = get_scene_for_key(key)
		
		
		for i in count:
			var instance = scene_to_spawn.instantiate()
			
			instance.id_pair = id
			
			second_background.add_child(instance)
			instance.global_position.x = pos_x[0]
			instance.global_position.y = pos_y[0]
			
			pos_x.remove_at(0)
			pos_y.remove_at(0)
			id += 1
			
			second_background.manual_init()
			spawned_objects.append(instance)


func get_scene_for_key(key: String) -> PackedScene:
	if "Plastik 1" in key:
		return Plastic_1
	elif "Plastik 2" in key:
		return Plastic_2
	elif "Plastik 3" in key:
		return Plastic_3
	else:
		return Plastic_1  # Default fallback
