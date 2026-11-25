extends RigidBody2D

var speed = 12
@export var PP : Sprite2D
@export var PE : Sprite2D
@export var PET : Sprite2D
var type : String

func shoot(pos, number):
	if number == 1:
		PP.visible = true
		PE.visible = false
		PET.visible = false
		type = "PP"
		
	if number == 2:
		PP.visible = false
		PE.visible = true
		PET.visible = false
		type = "PE"
		
	if number == 3:
		PP.visible = false
		PE.visible = false
		PET.visible = true
		type = "PET"
	
	linear_velocity = speed * -pos

func _process(_delta: float) -> void:
	if linear_velocity.y > 0:
		self.z_index = 1
