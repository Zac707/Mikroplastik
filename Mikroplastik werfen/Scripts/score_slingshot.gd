extends Label

@export var score: LocalScore

func _ready():
	score.connect("score_changed",_on_score_changed)
	text = "Score: " + str(score.score)  # initial score

func _on_score_changed(new_value):
	self.text = "Score: " + str(new_value)
