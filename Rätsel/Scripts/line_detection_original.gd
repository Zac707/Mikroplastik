extends Area2D


var line_direction
var occupied_directions: Array = []
var original_directions : Array[Vector2]
var point_made = 0
var points
var last_exit_direction = null  # NEW: Store the actual exit direction
var first_entry_direction = null
var first_entry_points = null
var first_exit_direction = null
var area_id

@export var allowed_directions: Array[Vector2]


func _ready() -> void:
	original_directions = allowed_directions.duplicate()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Line_Rätsel"):
		var pos = self.global_position
		if point_made == 0:
			line_direction = area.current_direction
			point_made += 1
			last_exit_direction = null  # Reset
			first_entry_direction = area.control_area.get_entry_point()
			print("line_direction: ", line_direction, "first_entry_direction: ", first_entry_direction)
			area.control_area.direction_history.append(allowed_directions.duplicate())
			points = area.control_area.direction_history.size()
			first_entry_points = points
			area_id = area.get_instance_id()
			area.create_new_point(pos)
			# Hier wird ein neuer Punkt erstellt. Die Ausrichtung der Linie wird in line_direction gespeichert damit beim Rückgang der Punkt gelöscht werden kann.
			# last_exit-direction speichert die Richtung wo die linie rausgeht, heir wird sie auf null gesetzt. first_entry direction macht dasselbe wie line_direction, wird
			# aber für andere zwecke gebraucht. points speichert die Linienlänge beim ersten Eintritt.
		elif point_made >= 1 and points == area.control_area.direction_history.size() and area.get_instance_id() == area_id:
			remove_stored_exit_direction()
			area.control_area.direction_history[-1] = allowed_directions.duplicate()
			# Logik wenn die Linie wieder die area entered, aber schonmal hier war und nicht eine Umrundung gemacht hat.
		elif (point_made >= 1 and points != area.control_area.direction_history.size()) or (point_made >= 1 and area.get_instance_id() != area_id):
			line_direction = area.current_direction
			point_made += 1
			add_entry_to_occupied_directions(area, first_entry_direction)
			
			area.control_area.direction_history.append(allowed_directions.duplicate())
			points = area.control_area.direction_history.size()
			area.create_new_point(pos)
			# wird aufgerufen wenn die Linie dieselbe area zum zweiten mal entered. Line_direction wird hier voin diesem zweiten Eingang aktualisiert,first_entry_direction bleibt aber
			# erhalten. Die Größe der Linie in points wird ebendfalls aktualisiert, damit der obere Fall weiterhin genutzt werden kann.Im grunde selbe Logik wie die allererste
			# if funktion, nur dass hier der first_entry_direction zu den occupied_directions hinzugefügt wird.


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Line_Rätsel"):
		var line = area.line
		var points_count = line.get_point_count()
		if points_count > 1:
			var prev_point = line.to_global(line.points[points_count - 2])
			if self.global_position == prev_point and area.current_direction == -line_direction:
				point_made -= 1
				# wird getriggert wenn die Linie aus derselben Richtung verlässt wie sie reinkam, gespeichert über line_direction.
				
				remove_entry_from_occupied_directions(area)
				# Versuch bei der Rückkehr Backtracking auch nach zwei Berührungen zu erlauben
				var history_size = area.control_area.direction_history.size() -1
				area.control_area.direction_history.remove_at(history_size)
				area.delete_point()
			else:
				add_exit_to_occupied_directions(area)
				# wird getriggert wenn die Are aus einer anderen Richtung verlassen wird
				area.control_area.direction_history[-1] = allowed_directions.duplicate()


func remove_stored_exit_direction():
	if point_made > 1 and last_exit_direction in occupied_directions:
		occupied_directions.erase(last_exit_direction)
		# last-exit_direction wird beim verlassen der area in einer Richtung die nicht backtrackt gesetzt. Diese wird aus occupied_directions entfernt.
		allowed_directions = original_directions.duplicate()
		for occupied_dir in occupied_directions:
			if occupied_dir in allowed_directions:
				allowed_directions.erase(occupied_dir)
		# grundsätzliche Logik um die allowed_directions neu zu initialisieren.
		print("allowed_directions after re-entry: ", allowed_directions)
		last_exit_direction = null
		
	if point_made <= 1 and first_exit_direction in occupied_directions:
		occupied_directions.erase(first_exit_direction)
		# last-exit_direction wird beim verlassen der area in einer Richtung die nicht backtrackt gesetzt. Diese wird aus occupied_directions entfernt.
		allowed_directions = original_directions.duplicate()
		for occupied_dir in occupied_directions:
			if occupied_dir in allowed_directions:
				allowed_directions.erase(occupied_dir)
		# grundsätzliche Logik um die allowed_directions neu zu initialisieren.
		print("allowed_directions after re-entry: ", allowed_directions)
		last_exit_direction = null


func add_entry_to_occupied_directions(area, dir):
	var entry_direction = dir
	if entry_direction not in occupied_directions:
		occupied_directions.append(entry_direction)
	# wird aktiviert beim zweiten Eingang in derselben area. Die ursprünglich gespeicherte Eingangsrichtung wird jetzt zu den blockierten Richtungen hinzugefügt.
	allowed_directions = original_directions.duplicate()
	for occupied_dir in occupied_directions:
		if occupied_dir in allowed_directions:
			allowed_directions.erase(occupied_dir)
	
	print("allowed_directions after entry: ", allowed_directions)


func remove_entry_from_occupied_directions(area):
	var entry_direction = area.control_area.get_entry_point()
	if entry_direction in occupied_directions:
		occupied_directions.erase(entry_direction)
		# entfernt den genutzte Eingang aus occupied directions
	if first_entry_direction in occupied_directions:
		occupied_directions.erase(first_entry_direction)
	if point_made > 0:
		line_direction = -first_entry_direction
		points = first_entry_points
		print("line_direction: ", line_direction, "first_entry_direction: ", first_entry_direction)
	
	allowed_directions = original_directions.duplicate()
	for occupied_dir in occupied_directions:
		if occupied_dir in allowed_directions:
			allowed_directions.erase(occupied_dir)
	
	print("allowed_directions after entry removal: ", allowed_directions)


func add_exit_to_occupied_directions(area):
	var exit_direction = area.control_area.get_exit_point()
	if point_made > 1:
		last_exit_direction = exit_direction 
	else:
		first_exit_direction = exit_direction
	 # STORE IT
	if exit_direction not in occupied_directions:
		occupied_directions.append(exit_direction)
		# hier wird last_exit_direction festgelegt. PROBLEM: Diese Variable wird beim zweiten sowie beim ersten Eingang gesetzt. Beim zweiten Eingang wird das erste Verlassen vergessen.
		# wenn dann gebacktrackt wird, hat die remove_stored_exit_direction Funktion keinen Zugriff auf die erste Richtung in der verlassen wurde, weshalb die geblockt wird.
		# Bei line_direction grundsätzlich dasselbe, wird beim neuen Eingang neu gesetzt und kann bei Rückkehr nicht entfernt werden. hier muss nur die line_direction zurück auf 
		# first_entry position gesetzt werden.
	
	allowed_directions = original_directions.duplicate()
	for occupied_dir in occupied_directions:
		if occupied_dir in allowed_directions:
			allowed_directions.erase(occupied_dir)
	
	print("allowed_directions after exit: ", allowed_directions)
