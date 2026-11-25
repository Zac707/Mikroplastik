extends Area2D

@export var colour : String
@export var PP : Node2D
@export var PE : Node2D
@export var PET : Node2D
@export var score: LocalScore

func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("Projectile") and colour == body.type:
		if body.linear_velocity.y > 0:
			score.add_points(1)
			body.queue_free()
	elif body.is_in_group("Projectile") and colour != body.type:
		if body.linear_velocity.y > 0:
			score.add_points(-1)
			body.queue_free()

func _ready() -> void:
	
	if colour == "PP":
		PP.visible = true
		PE.visible = false
		PET.visible = false

	if colour == "PE":
		PP.visible = false
		PE.visible = true
		PET.visible = false

	if colour == "PET":
		PP.visible = false
		PE.visible = false
		PET.visible = true
