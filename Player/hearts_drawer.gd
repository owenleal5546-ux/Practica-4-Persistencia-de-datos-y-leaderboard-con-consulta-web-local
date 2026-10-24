extends Control

var hud: Node = null

func _ready() -> void:
	hud = get_parent()

func _draw() -> void:
	if not hud:
		return
	
	var max_hearts: int = hud.get("max_hearts") if "max_hearts" in hud else 3
	var current_hearts: int = hud.get("current_hearts") if "current_hearts" in hud else 3

	var heart_pixels = [
		Vector2i(1, 0), Vector2i(2, 0), Vector2i(4, 0), Vector2i(5, 0),
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1),
		Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2),
		Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3),
		Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4),
		Vector2i(3, 5)
	]

	var active_color = Color(0.95, 0.15, 0.2, 1.0)
	var empty_color = Color(0.25, 0.25, 0.28, 0.6)
	var border_color = Color(0.1, 0.05, 0.05, 0.9)

	var start_pos = Vector2(10, 10)
	var spacing = 12

	for h in range(max_hearts):
		var h_pos = start_pos + Vector2(h * spacing, 0)
		var is_filled = (h < current_hearts)
		var fill_col = active_color if is_filled else empty_color

		for p in heart_pixels:
			draw_rect(Rect2(h_pos.x + p.x, h_pos.y + p.y + 1, 1, 1), border_color)
		for p in heart_pixels:
			draw_rect(Rect2(h_pos.x + p.x, h_pos.y + p.y, 1, 1), fill_col)
