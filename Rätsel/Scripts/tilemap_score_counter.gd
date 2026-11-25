extends TileMapLayer

@export var score_manager: LocalScore


func _ready():
	# Wait one frame for all scenes to be instantiated
	await get_tree().process_frame
	
	# Connect to all nodes in the group
	for node in get_tree().get_nodes_in_group("points_emitter"):
		if node.has_signal("points_earned"):
			node.points_earned.connect(_on_child_points_earned)


func _on_child_points_earned(amount: int):
	if score_manager:
		score_manager.add_points(amount)
