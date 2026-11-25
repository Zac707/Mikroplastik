class_name ObjectMinigameModifiers
extends RefCounted
## The modifiers from a (fished) object that can affect a minigame.


## The level of decay the object had when being fished.
## Higher decay should mean higher minigame difficulty.
var decay_level: Enums.Decay = Enums.Decay.NONE

## How many players were required to fish out this object.
## Will be used as the minimum number of choosable players in the Intro Panel.
var player_amount: int = 1


func _init(p_decay: Enums.Decay, p_amount: int) -> void:
	self.decay_level = p_decay
	self.player_amount = max(1, p_amount)
