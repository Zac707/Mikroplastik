extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is not FishingRB:
		return
	body = body as FishingRB
	body.left_throw_area = false
	print("Throw area entered")


func _on_body_exited(body: Node2D) -> void:
	if body is not FishingRB:
		return
	body = body as FishingRB
	body.apply_end_drag.call_deferred()
	body.left_throw_area = true
	print("Throw area exited")
