class_name PuddleVisual
extends Sprite2D


@export var spawn_time: float = 5.0
@export var expand_time: float = 3.0
@export var vanish_time: float = 10.0

var _start_scale: Vector2
var _start_alpha: float


var _tween: Tween

func _ready() -> void:
	_start_scale = scale
	_start_alpha = modulate.a
	
	scale = Vector2(0.01, 0.01)
	hide()


func spawn() -> void:
	show()
	
	_tween = _ensure_tween()
	_tween.tween_property(self, "scale", _start_scale, spawn_time)


func expand(factor: float) -> void:
	_tween = _ensure_tween()
	_tween.tween_property(self, "scale", _start_scale * factor, expand_time)


func vanish() -> void:
	_tween = _ensure_tween()
	_tween.tween_property(self, "scale", scale * 2, vanish_time)
	var target_color := Color(modulate, 0)
	_tween.parallel().tween_property(self, "modulate", target_color, vanish_time)
	_tween.tween_callback(queue_free)


func _ensure_tween() -> Tween:
	if _tween && _tween.is_running():
		_tween.kill()
	return create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
