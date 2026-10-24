extends Area2D

@export var points: int = 50

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player") or body is CharacterBody2D:
		var gm = get_node_or_null("/root/GameManager")
		if gm and gm.has_method("add_score"):
			gm.add_score(points)
		
		if body.has_method("add_score"):
			body.add_score(points)
		elif "score" in body:
			body.set("score", body.get("score") + points)
		
		var hud = body.get_node_or_null("PlayerHUD")
		if hud and hud.has_method("add_score"):
			hud.add_score(points)
			
		queue_free()
