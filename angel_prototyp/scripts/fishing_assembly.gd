class_name FishingRod
extends Node2D


static var _all_rods: Array[FishingRod] = []

## Static array of all fishing rods with a currently pressed reel_in_button
static var _actively_pressed: Array[FishingRod]

## Whether reel in has been called once already when multiple players are 
## reeling in an object.
static var _called_reel_once: bool


@export var throwable: FishingRB
@export var winch: Winch
@export var reel_in_button: MultiTouchButton
## Shows how many of the needed players to reel it in are attached to the object 
@export var reel_in_progress: RadialProgress
@export var detach_obj_button: MultiTouchButton

var _attached_obj: FishableObject


static func _append_actively_pressed(node: FishingRod) -> void:
	_actively_pressed.append(node)
	print_debug("Now pressed by: " + str(_actively_pressed))
	for rod in _all_rods:
		rod._on_pressed_count_changed(_actively_pressed.size())

static func _erase_actively_pressed(node: FishingRod) -> void:
	if !_actively_pressed.has(node):
		return
	_actively_pressed.erase(node)
	print_debug("Now pressed by: " + str(_actively_pressed))
	for rod in _all_rods:
		rod._on_pressed_count_changed(_actively_pressed.size())


func _ready() -> void:
	_all_rods.append(self)
	
	reel_in_button.hide()
	reel_in_button.pressed.connect(throwable.reel_in_object)
	reel_in_progress.hide()
	reel_in_progress.progress = 0
	detach_obj_button.hide()
	detach_obj_button.pressed.connect(throwable.detach_object)
	
	throwable.object_attached.connect(_on_catch)
	throwable.object_detached.connect(_on_detach)


func _on_catch(obj: FishableObject) -> void:
	_attached_obj = obj
	reel_in_button.show()
	detach_obj_button.show()
	
	if obj.needed_players > 1:
		reel_in_button.pressed.disconnect(throwable.reel_in_object)
		reel_in_button.pressed.connect(_on_reel_button_down)
		reel_in_button.button_up.connect(_on_reel_button_up)
		reel_in_progress.show()


func _on_pressed_count_changed(count: int) -> void:
	if _attached_obj == null:
		return
	
	var progress := clampf(float(count) / _attached_obj.needed_players, 0 , 1)
	reel_in_progress.progress = progress
	print("Setting progress to " + str(progress))
	
	if !_actively_pressed.has(self):
		return
	if progress < 1:
		return
	
	var mid := get_active_midpoint()
	throwable.reel_in_object(!_called_reel_once, mid)
	_called_reel_once = true


func _on_detach() -> void:
	reel_in_button.hide()
	detach_obj_button.hide()
	reel_in_progress.hide()
	
	if reel_in_button.pressed.is_connected(_on_reel_button_down):
		reel_in_button.pressed.disconnect(_on_reel_button_down)
	if reel_in_button.button_up.is_connected(_on_reel_button_up):
		reel_in_button.button_up.disconnect(_on_reel_button_up)
	
	if !reel_in_button.pressed.is_connected(throwable.reel_in_object):
		reel_in_button.pressed.connect(throwable.reel_in_object)
	
	reel_in_progress.progress = 0
	
	_attached_obj = null
	_erase_actively_pressed(self)
	if _actively_pressed.size() == 0:
		_called_reel_once = false


func _on_reel_button_down() -> void:
	_append_actively_pressed(self)


func _on_reel_button_up() -> void:
	_erase_actively_pressed(self)



func get_active_midpoint() -> Vector2:
	if _actively_pressed.is_empty():
		return Vector2.ZERO
	
	var sum := Vector2.ZERO
	for node in _actively_pressed:
		sum += node.global_position
	
	return sum / _actively_pressed.size()
