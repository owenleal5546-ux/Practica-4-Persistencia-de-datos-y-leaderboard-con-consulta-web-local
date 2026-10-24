class_name BloodDecal
extends Node2D

@export var lifetime: float = 5.0
@export var fade_time: float = 1.5

var _pixels: Array[Vector2i] = []
var _colors: Array[Color] = []

func _ready() -> void:
	z_index = 0
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var base_red = Color(0.65, 0.08, 0.12, 0.95)
	var dark_red = Color(0.45, 0.04, 0.07, 0.95)
	var bright_red = Color(0.85, 0.15, 0.18, 0.95)
	
	_pixels.append(Vector2i(0, 0))
	_colors.append(base_red)
	
	if rng.randf() > 0.3:
		_pixels.append(Vector2i(1, 0))
		_colors.append(dark_red)
	if rng.randf() > 0.4:
		_pixels.append(Vector2i(-1, 0))
		_colors.append(bright_red)
	if rng.randf() > 0.6:
		_pixels.append(Vector2i(0, 1))
		_colors.append(dark_red)
	if rng.randf() > 0.7:
		_pixels.append(Vector2i(rng.randi_range(-2, 2), 0))
		_colors.append(base_red)

	queue_redraw()

	var tween = create_tween()
	tween.tween_interval(maxf(0.1, lifetime - fade_time))
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	tween.tween_callback(queue_free)

func _draw() -> void:
	for i in range(_pixels.size()):
		draw_rect(Rect2(_pixels[i].x, _pixels[i].y, 1, 1), _colors[i])
