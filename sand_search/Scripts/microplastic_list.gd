extends Control

@export var text_label: Label
@export var sample_dictionary: Dictionary = {}

var pos_x : Array
var pos_y : Array
var display_text : String
var rng = RandomNumberGenerator.new()
var sum = 0
var min_distance = 80  # Minimum distance between positions
var new_x
var new_y 
var x_range : int
var y_range : int

signal dictionary_data_sent(dict: Dictionary, position_x: Array, position_y: Array)


func manual_init():
	display_text = ""
	
	if text_label == null:
		print("TextLabel not assigned!")
		return
	
	if sample_dictionary.is_empty():
		display_text += "(Empty dictionary)"
	else:
		for key in sample_dictionary.keys():
			display_text += str(key) + ": " + str(sample_dictionary[key]) + "\n"
		for value in sample_dictionary.values():
			sum += value
	
	generate_positions_with_min_distance(sum)
	
	text_label.text = display_text
	
	GlobalList.dic = sample_dictionary.duplicate()
	dictionary_data_sent.emit(sample_dictionary, pos_x, pos_y)



func generate_positions_with_min_distance(count: int) -> void:
	pos_x.clear()
	pos_y.clear()
	
	var max_attempts = 1000  # Prevent infinite loops
	
	for i in count:
		var attempts = 0
		var valid_position = false
		
		while not valid_position and attempts < max_attempts:
			new_x = rng.randi_range(-x_range, x_range)
			new_y = rng.randi_range(-y_range, y_range) 
			
			valid_position = true
			
			# Check distance from all existing positions
			for j in pos_x.size():
				var distance = sqrt(pow(new_x - pos_x[j], 2) + pow(new_y - pos_y[j], 2))
				if distance < min_distance:
					valid_position = false
					break
			
			attempts += 1
		
		if valid_position:
			pos_x.append(new_x)
			pos_y.append(new_y)
		else:
			print("Warning: Could not find valid position for particle ", i, " after ", max_attempts, " attempts")
			# Fallback: add position anyway to avoid missing particles
			pos_x.append(new_x)
			pos_y.append(new_y)


func update():
	sample_dictionary = GlobalList.dic.duplicate()
	display_text = ""

	for key in sample_dictionary.keys():
		display_text += str(key) + ": " + str(sample_dictionary[key]) + "\n"
	text_label.text = display_text
