class_name MinigameResultData
extends RefCounted
## Data carrier for the results of a minigame.
## Made so MinigameSetup does not have to be changed if these results change.


var score: int


@warning_ignore("shadowed_variable")
func _init(score: int) -> void:
	self.score = score
