class_name PlayerHUD
extends CanvasLayer

@export var max_hearts: int = 3
var current_hearts: int = 3
var score: int = 0

@onready var score_label: Label = get_node_or_null("ScoreLabel")

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_signal("score_changed"):
		if not gm.score_changed.is_connected(update_score):
			gm.score_changed.connect(update_score)
		update_score(gm.score)

func setup(max_hp: int, current_hp: int) -> void:
	max_hearts = max_hp
	current_hearts = current_hp
	if has_node("Control"):
		$Control.queue_redraw()

func update_health(current_hp: int) -> void:
	current_hearts = current_hp
	if has_node("Control"):
		$Control.queue_redraw()

func add_score(amount: int) -> void:
	score += amount
	update_score(score)

func update_score(new_score: int) -> void:
	score = new_score
	if score_label:
		score_label.text = "Score: %d" % score
