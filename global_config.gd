class_name GlobalConfig
extends Node



# --- Total Progress ---

## The total progress to reach from minigame scores to win the game.
const total_progress_goal: int = 30


# --- Pollution ---

## Maximum level of pollution the pond can have. Game Over when reached.
const max_pollution_amount: int = 1000

## How much pollution one FishableObject changing to the next decay level
## adds to the pond pollution.
const decay_lvl_change_pollution: int = 2


# --- Decay ---

## How many seconds a FishableObject takes to change to the next decay level.
const seconds_per_decay_level: int = 30

## Randomization space applied to seconds_per_decay_level in both positive and
## negative direction.
## Example:
## seconds_per_decay_level = 60 and randomization = 10
## value used by FishableObjects is between 50 & 70
const decay_time_randomization: int = 10
