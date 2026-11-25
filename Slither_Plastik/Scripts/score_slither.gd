extends Label

@export var score_manager: LocalScore

func _ready():
	score_manager.connect("score_changed",_on_score_changed)
	text = "Score: " + str(score_manager.score)  # initial score

func _on_score_changed(new_value):
	self.text = "Score: " + str(new_value)
