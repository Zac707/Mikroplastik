class_name ProgressCleanEvent
extends ProgressEvent
## A Progress Event that can remove pollution from the global pollution level
## and FishableObjects from the grid.

## Remove an amount of pollution from the global pollution level based on 
## max possible pollution.
@export_range(0, 1, 0.01) var pollution_clean_percent: float

## Whether to remove objects based on the "Object Remove Percentage" or
## on the "Object Remove Count"
@export var object_remove_use_percentage: bool = true

## Remove an amount of Fishable Objects from the grid based on a
## percentage of the current amount of spawned objects.
@export_range(0, 1, 0.01) var object_remove_percentage: float

## Remove a set amount of Fishable Objects from the grid.
@export var object_remove_count: int


func execute(params: Object = null) -> void:
	var need_obj_spawner := (object_remove_percentage > 0.0 
		if object_remove_use_percentage else object_remove_count > 0)
	if (!params || params is not Params) && !need_obj_spawner:
		push_error("Clean progress event did not get necessary params.")
		return
	
	PollutionManager.instance.remove_pollution_percentage(pollution_clean_percent)
	
	params = params as Params
	if object_remove_use_percentage:
		params.object_spawner.remove_random_objects_percentage(object_remove_percentage)
	else:
		params.object_spawner.remove_random_objects(object_remove_count)


class Params:
	var object_spawner: GridObjectSpawner
	
	func _init(spawner: GridObjectSpawner) -> void:
		object_spawner = spawner
