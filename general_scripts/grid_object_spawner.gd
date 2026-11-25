class_name GridObjectSpawner
extends Node

## Emitted when no empty cell can be found when trying to spawn an object.
signal grid_filled

static var instance: GridObjectSpawner


@export_group("Config")
## Scenes of FishableObjects to spawn
@export var objects: Array[PackedScene] = []
## Time between single objects spawning
@export var spawn_interval: float = 60.0
## Whether to balance Object Type counts / Always spawn the FishableObject type
## that currently has less representatives
@export var balance_spawns: bool = true

@export_group("Initial Spawn")
## How many objects to spawn on game start
@export var initial_amount: int = 20
## How many of the grids cells to fill in percent / 1
@export_range(0, 1) var initial_percent: float = 0.75
## Whether to use percent or total amount of initially spawned objects
@export var init_use_percent: bool = true
## Time between objects of the initial wave spawning. Set to 0 to wait 1 frame.
@export var init_spawn_interval: float = 0.0
## Whether to use the manual_picks array for the distribution of initially spawned
## objects or pick randomly instead.
@export var init_pick_manually: bool = false
## Weighted distribution to use for the inital spawn if init_pick_manually is true. [br]
## E.g. if the elements sum up to 100, this is the same as percentage distribution.
@export var init_manual_distribution: Array[int] = []

@export_group("Refs")
@export var grid: Grid2D


var spawn_timer: Timer


func _ready() -> void:
	instance = self
	
	assert(grid, "Object Spawner has no grid assigned")
	assert(objects.size() > 0, "Object spawner has no object scenes assigned")
	if init_pick_manually:
		assert(init_manual_distribution.size() == objects.size(), 
			"Initial spawn picks size mismatch with objects")
	grid.clear()
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_timeout_spawn)
	add_child(spawn_timer, InternalMode.INTERNAL_MODE_BACK)
	spawn_timer.start()
	
	_spawn_initial_wave.call_deferred()


func _spawn_initial_wave() -> void:
	var amount := int(grid.cells.size() * initial_percent) \
		if init_use_percent else initial_amount
	print("Spawning %s initial fishable objects" % amount)
	for i in amount:
		var grid_pos = _try_get_random_grid_pos()
		if !grid_pos: return
		grid_pos = grid_pos as Vector2i
		
		# Distribution not taken from the array -> random distribution
		if !init_pick_manually:
			var rand_idx = randi_range(0, objects.size() - 1)
			var rand_scene: PackedScene = objects.get(rand_idx)
			_spawn_object(rand_scene, grid_pos, rand_idx)
		else:
			var scene := _get_weighted_random_object()
			if !scene:
				push_error("ObjectSpawner: Something went wrong when picking a " +\
					"FishableObject based on weight")
				return
			var idx := objects.find(scene)
			_spawn_object(scene, grid_pos, idx)
		
		# Always wait at least 1 frame or the objects are not registered with the grid
		# and multiple objects can spawn in the same cell
		await get_tree().process_frame
		
		if init_spawn_interval > 0:
			await get_tree().create_timer(init_spawn_interval).timeout


## Triggers a spawn for an object on a random unoccupied grid cell. [br]
## If balance_spawns is false, picks a random object to spawn. [br]
## If balance_spawns is true, picks a random object of the least spawned 
## objects to spawn.
func _on_timeout_spawn() -> void:
	var grid_pos = _try_get_random_grid_pos()
	if !grid_pos: return
	grid_pos = grid_pos as Vector2i
	
	if !balance_spawns:
		var rand_idx = randi_range(0, objects.size() - 1)
		var rand_scene: PackedScene = objects.get(rand_idx)
		_spawn_object(rand_scene, grid_pos, rand_idx)
		return
	
	var least_spawned_idx := _get_least_spawned_type()
	var scene: PackedScene = objects.get(least_spawned_idx)
	_spawn_object(scene, grid_pos, least_spawned_idx)


func _spawn_object(scene: PackedScene, grid_pos: Vector2i, obj_index: int) -> void:
	var obj = scene.instantiate()
	if obj is not FishableObject:
		push_error("Instantiated object " + obj.name + " is not a FishableObject type.")
		obj.queue_free()
		return
	
	obj = obj as FishableObject
	obj.set_meta("object_index", obj_index)
	obj.position = grid_pos
	grid.add_child(obj)


func remove_random_objects(amount: int) -> void:
	if grid.cells.size() < 1:
		return
	
	var contents := grid.get_all_cell_contents()
	var removed: int = 0
	while removed < amount:
		if contents.size() < 1:
			break
		
		var node: Node2D = contents.pick_random()
		if node && node is FishableObject:
			node.queue_free()
			removed += 1
		contents.erase(node)
	print("ObjectSpawner: Removed %s objects" % removed)


## Removes an amount of Fishable Objects from the grid based on a
## percentage of the current amount of spawned objects.
func remove_random_objects_percentage(percent: float) -> void:
	assert(percent >= 0 || percent <= 1, "Percentage to remove has to be between 0 and 1")
	
	var amount := int(percent * grid.get_all_cell_contents().size())
	remove_random_objects(amount)


## Returns the index in [member GridObjectSpawner.objects] of the object with
## the least spawned instances.
func _get_least_spawned_type() -> int:
	var spawned := grid.get_all_cell_contents()
	var counts: Dictionary[int, int] = {}
	for i in objects.size():
		counts[i] = 0
	
	for node in spawned:
		var obj_index: int = node.get_meta("object_index")
		if obj_index == null:
			push_error("ObjectSpawner: Grid node [" + node.name + "] has no " +\
				"metadata pointing to the object it was spawned from.")
			continue
		if obj_index < 0 || obj_index >= objects.size():
			push_error("ObjectSpawner: Index [%s] of node [%s] is out of range" %\
				[str(obj_index), node.name])
			continue
		
		if counts.has(obj_index):
			counts[obj_index] += 1
		else:
			counts.set(obj_index, 1)
			push_error("Least spawned object count: got an index that was not " +\
				"in the setup: " + str(obj_index))
	
	if counts.is_empty():
		return randi_range(0, objects.size() - 1)
	
	return _get_random_lowest(counts)


## Returns the key of the dictionary entry with the lowest value.
## If there are multiple entries with the same lowest value, returns
## a random pick from those.
func _get_random_lowest(source: Dictionary[int, int]) -> int:
	var min_value = source.values().min()
	var candidates: Array[int] = []
	for key in source.keys():
		if source[key] == min_value:
			candidates.append(key)
	
	return candidates.pick_random()


## Gets the position of a random unoccupied cell in the grids local space. [br]
## Returns [code]null[/code] if no cell was found or the position was invalid. [br]
## Returns a Vector2i otherwise.
func _try_get_random_grid_pos(default: Variant = null) -> Variant:
	var cell := grid.get_random_cell()
	if cell == Vector2i(-1, -1):
		push_error("ObjectSpawner: got no valid random cell position")
		grid_filled.emit()
		return default
	var grid_pos := grid.get_cell_position(cell)
	if grid_pos == Vector2i(-1, -1):
		return default
	return grid_pos


## Weighted pick of a [FishableObject] [PackedScene] based on the 
## init_manual_distribution array.
func _get_weighted_random_object() -> PackedScene:
	if objects.is_empty() or init_manual_distribution.size() != objects.size():
		push_error("ObjectSpawner: objects and weights must have the same non-zero length")
		return null
	
	# Calculate total weight
	var total_weight: int = init_manual_distribution.reduce(func(acc, sum): return acc + sum)
	if total_weight <= 0:
		push_error("ObjectSpawner: total weight must be greater than 0")
		return null
	
	# Pick a random value within total weight
	var rand_value := randi_range(1, total_weight)
	var cumulative := 0
	
	for i in objects.size():
		cumulative += init_manual_distribution[i]
		if rand_value <= cumulative:
			return objects[i]
	
	return null # Should never happen, but for safety
