extends Node

var dic : Dictionary

func on_dic_changed():
	if !get_tree():
		return
	var microplastic_node = get_tree().get_first_node_in_group("Microplastic_list")
	if microplastic_node:
		microplastic_node.update()
