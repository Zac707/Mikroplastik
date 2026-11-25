class_name LocalScore
extends Node

var score: int = 0
var players_finished: int = 0

signal score_changed(new_score: int)
signal player_count_changed(player_nr: int)


func add_points(points: int):
	score += points
	score_changed.emit(score)

func check_player_count(player_count: int):
	players_finished += player_count
	print("Players finished: ", players_finished, "Score: ", score)
	player_count_changed.emit(players_finished, score)
