extends Area2D


var occupied_directions: Array = []
var original_directions : Array[Vector2]
var points_made = 0
# var first_player_entry_direction = null  # REMOVED: using per-player data instead

# Dictionary to track each player/line separately
var player_data = {}  # Key: area_id, Value: {line_direction, point_made, points, last_exit, first_entry, first_exit, first_entry_points}

@export var allowed_directions: Array[Vector2]


func _ready() -> void:
	original_directions = allowed_directions.duplicate()


func get_player_data(area_id):
	# Initialize player data if it doesn't exist
	if not player_data.has(area_id):
		player_data[area_id] = {
			"line_direction": Vector2.ZERO,
			"point_made": 0,
			"points": 0,
			"last_exit_direction": null,
			"first_entry_direction": null,
			"first_exit_direction": null,
			"first_entry_points": null
		}
	return player_data[area_id]


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Line_Rätsel"):
		var pos = self.global_position
		var area_id = area.get_instance_id()
		var data = get_player_data(area_id)
		print("LinienPunkte: ", data.point_made, " Gesamtpunkte: ", points_made)
		
		if data.point_made == 0 and points_made == 0:
			data.line_direction = area.current_direction
			data.point_made += 1
			data.last_exit_direction = null
			data.first_entry_direction = area.control_area.get_entry_point()
			
			# store per-player first entry
			print("Player ", area_id, " - line_direction: ", data.line_direction, " first_entry_direction: ", data.first_entry_direction)
			
			points_made += 1
			area.control_area.direction_history.append(allowed_directions.duplicate())
			data.points = area.control_area.direction_history.size()
			data.first_entry_points = data.points
			area.create_new_point(pos)
			
		elif data.point_made >= 1 and data.points == area.control_area.direction_history.size():
			remove_stored_exit_direction(area_id)
			area.control_area.direction_history[-1] = allowed_directions.duplicate()
			
		elif data.point_made >= 1 and data.points != area.control_area.direction_history.size():
			data.line_direction = area.current_direction
			data.point_made += 1
			# use this player's first_entry_direction (per-player) rather than a global
			add_entry_to_occupied_directions(area, data.first_entry_direction)
			
			print("third function called")
			points_made += 1
			area.control_area.direction_history.append(allowed_directions.duplicate())
			data.points = area.control_area.direction_history.size()
			area.create_new_point(pos)
		
		elif data.point_made == 0 and points_made > 0:  
			data.line_direction = area.current_direction
			data.point_made += 1
			data.last_exit_direction = null
			data.first_entry_direction = area.control_area.get_entry_point()
			
			# use this player's first_entry_direction (per-player)
			add_entry_to_occupied_directions(area, data.first_entry_direction)
			
			print("Fourth function called - new player entering")
			points_made += 1
			area.control_area.direction_history.append(allowed_directions.duplicate())
			data.points = area.control_area.direction_history.size()
			data.first_entry_points = data.points
			area.create_new_point(pos)


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Line_Rätsel"):
		var line = area.line
		var points_count = line.get_point_count()
		var area_id = area.get_instance_id()
		var data = get_player_data(area_id)
		
		if points_count > 1:
			var prev_point = line.to_global(line.points[points_count - 2])
			if self.global_position == prev_point and area.current_direction == -data.line_direction:
				data.point_made -= 1
				points_made -= 1
				remove_entry_from_occupied_directions(area, area_id)
				
				var history_size = area.control_area.direction_history.size() - 1
				area.control_area.direction_history.remove_at(history_size)
				area.delete_point()
			else:
				# when an exit happens, block the player's first entry direction immediately
				add_exit_to_occupied_directions(area, area_id)
				area.control_area.direction_history[-1] = allowed_directions.duplicate()


func remove_stored_exit_direction(area_id):
	var data = get_player_data(area_id)
	
	if data.point_made > 1  and data.last_exit_direction in occupied_directions:
		occupied_directions.erase(data.last_exit_direction)
		allowed_directions = original_directions.duplicate()
		for occupied_dir in occupied_directions:
			if occupied_dir in allowed_directions:
				allowed_directions.erase(occupied_dir)
		data.last_exit_direction = null
	
	if data.point_made <= 1  and data.first_exit_direction in occupied_directions:
		occupied_directions.erase(data.first_exit_direction)
		allowed_directions = original_directions.duplicate()
		for occupied_dir in occupied_directions:
			if occupied_dir in allowed_directions:
				allowed_directions.erase(occupied_dir)
		data.first_exit_direction = null
	
	# FREE the player's own first_entry_direction when remove_stored_exit_direction is called
	# (this corresponds to "free it as soon as remove_stored_exit_direction gets called")
	if data.first_entry_direction and data.first_entry_direction in occupied_directions:
		occupied_directions.erase(data.first_entry_direction)
		allowed_directions = original_directions.duplicate()
		for occupied_dir in occupied_directions:
			if occupied_dir in allowed_directions:
				allowed_directions.erase(occupied_dir)
		# keep data.first_entry_direction intact as a record; we only clear the blocking
		# if you want to reset the saved entry after freeing, uncomment the next line:
		# data.first_entry_direction = null
	
	print("allowed_directions after re-entry: ", allowed_directions)


func add_entry_to_occupied_directions(_area, dir):
	var entry_direction = dir
	if entry_direction == null:
		# nothing to add (safety)
		return
	if entry_direction not in occupied_directions:
		occupied_directions.append(entry_direction)
	
	allowed_directions = original_directions.duplicate()
	for occupied_dir in occupied_directions:
		if occupied_dir in allowed_directions:
			allowed_directions.erase(occupied_dir)
	
	print("allowed_directions after entry: ", allowed_directions)


func remove_entry_from_occupied_directions(_area, area_id):
	var data = get_player_data(area_id)
	
	if data.first_entry_direction and data.first_entry_direction in occupied_directions:
		occupied_directions.erase(data.first_entry_direction)
	
	if data.point_made > 0:
		data.line_direction = -data.first_entry_direction
		data.points = data.first_entry_points
		print("Player ", area_id, " - line_direction: ", data.line_direction, " first_entry_direction: ", data.first_entry_direction)
	
	allowed_directions = original_directions.duplicate()
	for occupied_dir in occupied_directions:
		if occupied_dir in allowed_directions:
			allowed_directions.erase(occupied_dir)
	
	print("allowed_directions after entry removal: ", allowed_directions)


func add_exit_to_occupied_directions(area, area_id):
	var data = get_player_data(area_id)
	var exit_direction = area.control_area.get_exit_point()
	
	if data.point_made > 1:
		data.last_exit_direction = exit_direction
	else:
		data.first_exit_direction = exit_direction
	
	# existing behavior: block the exit direction
	if exit_direction not in occupied_directions:
		occupied_directions.append(exit_direction)
	
	# NEW: also block this player's first_entry_direction immediately when they exit
	# (so the first entry is blocked as soon as add_exit_to_occupied_directions is called)
	if data.first_entry_direction and data.first_entry_direction not in occupied_directions:
		occupied_directions.append(data.first_entry_direction)
	
	allowed_directions = original_directions.duplicate()
	for occupied_dir in occupied_directions:
		if occupied_dir in allowed_directions:
			allowed_directions.erase(occupied_dir)
	
	print("allowed_directions after exit: ", allowed_directions)
