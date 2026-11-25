class_name PollutionManager
extends Node
## Manages the pollution level of the fishing pond.


signal max_pollution_reached

static var instance: PollutionManager

@export var _progress_label: Label
@export var puddle_container: Node
@export var _water_layer: Node2D
@export var _pollution_water_gradient: Gradient

var _max_pollution: int = 1000
var _current_pollution: int = 0:
	set (value):
		_current_pollution = value
		if _progress_label:
			var decimal := float(_current_pollution)/_max_pollution
			var percent := str(int(decimal * 100)) + "%"
			_progress_label.text = percent
			#print("Setting to: ", percent)
		if _water_layer:
			_adjust_water_color()


func _init() -> void:
	instance = self
	
	_max_pollution = GlobalConfig.max_pollution_amount


func _ready() -> void:
	_current_pollution = 0
	_adjust_water_color()


## Adds an amount to the current pollution.
## Has to be a positive value; negative values are clamped.
func add_pollution(amount: int) -> void:
	# Do not add pollution or call events when max is already reached
	if _current_pollution >= _max_pollution:
		return
	
	amount = clampi(amount, 0, _max_pollution - _current_pollution)
	_current_pollution += amount
	
	if _current_pollution < _max_pollution:
		return
	
	print("---- GAME OVER ----")
	print("---- Max pollution reached ----")
	# TODO: Some kind of UI / Animation
	max_pollution_reached.emit()


## Removes an amount from the current pollution.
## Has to be a positive value; negative values are clamped.
func remove_pollution(amount: int) -> void:
	amount = clampi(amount, 0, _current_pollution)
	_current_pollution -= amount


## Removes the given percentage of pollution relative to the max pollution.
func remove_pollution_percentage(percent: float) -> void:
	assert(percent >= 0 || percent <= 1, "Percentage to remove has to be between 0 and 1")
	
	var amount := int(percent * _max_pollution)
	remove_pollution(amount)


func _adjust_water_color() -> void:
	var pollution_ratio = clampf(float(_current_pollution) / float(_max_pollution), 0, 1)
	_water_layer.modulate = _pollution_water_gradient.sample(pollution_ratio)
