extends Node

var score: int = 0
var carrots_collected: int = 0

signal score_changed(new_score: int)

func add_score(amount: int = 10) -> void:
	score += amount
	carrots_collected += 1
	score_changed.emit(score)
	var db = get_node_or_null("/root/DatabaseManager")
	if db and db.has_method("record_coin"):
		db.record_coin()

func reset_score() -> void:
	score = 0
	carrots_collected = 0
	score_changed.emit(score)
