extends Area2D

var sibling_instances = []
var pair_id : int
var sibling_found = false
var is_being_removed = false  # NEW: Track if removal is in progress

@export var plastic_type : String


func _ready():
	pair_id = get_parent().id_pair
	find_sibling_by_pair_id()


func removal():
	if is_being_removed:
		return  # Already being removed, don't do anything
	
	is_being_removed = true
	
	# Decrement ONCE for the pair
	if GlobalList.dic.has(plastic_type):
		GlobalList.dic[plastic_type] -= 1
		GlobalList.on_dic_changed()
	
	# Mark siblings as being removed
	for sibling in sibling_instances:
		if sibling and is_instance_valid(sibling):
			sibling.is_being_removed = true
	
	# Free siblings
	for sibling in sibling_instances:
		if sibling and is_instance_valid(sibling):
			sibling.get_parent().queue_free()
	
	# Free self
	get_parent().queue_free()


func find_sibling_by_pair_id():
	var group_members = get_tree().get_nodes_in_group("Plastic_sand_hitbox")
	for member in group_members:
		if member.pair_id == self.pair_id and member != self:
			sibling_instances.append(member)
			member.get_sibling(self)
			sibling_found = true


func get_sibling(sibling):
	if sibling not in sibling_instances:
		sibling_instances.append(sibling)
