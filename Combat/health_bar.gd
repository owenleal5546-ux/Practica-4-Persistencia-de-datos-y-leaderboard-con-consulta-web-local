class_name HealthBar
extends Node2D

@export var bar_width: int = 16
@export var bar_height: int = 3
@export var border_color: Color = Color(0.1, 0.1, 0.1, 1.0)
@export var bg_color: Color = Color(0.2, 0.05, 0.05, 0.9)
@export var fill_color: Color = Color(0.9, 0.15, 0.15, 1.0)
@export var auto_hide: bool = true
@export var hide_delay: float = 3.0

var max_hp: int = 2
var current_hp: int = 2
var _hide_timer: float = 0.0

func _ready() -> void:
	if auto_hide:
		visible = false

func _process(delta: float) -> void:
	if auto_hide and visible and _hide_timer > 0:
		_hide_timer -= delta
		if _hide_timer <= 0:
			visible = false

func setup(p_max: int, p_current: int) -> void:
	max_hp = maxi(1, p_max)
	current_hp = clampi(p_current, 0, max_hp)
	queue_redraw()

func update_health(p_current: int, p_max: int = -1) -> void:
	if p_max > 0:
		max_hp = p_max
	current_hp = clampi(p_current, 0, max_hp)
	visible = true
	_hide_timer = hide_delay
	queue_redraw()

func _draw() -> void:
	var x_offset = -int(bar_width / 2.0)
	var y_offset = -int(bar_height / 2.0)
	
	# Border rect (1px outline)
	draw_rect(Rect2(x_offset - 1, y_offset - 1, bar_width + 2, bar_height + 2), border_color, true)
	# Background
	draw_rect(Rect2(x_offset, y_offset, bar_width, bar_height), bg_color, true)
	
	# Fill rect
	if max_hp > 0 and current_hp > 0:
		var fill_ratio = float(current_hp) / float(max_hp)
		var fill_w = int(round(bar_width * fill_ratio))
		fill_w = clampi(fill_w, 1 if current_hp > 0 else 0, bar_width)
		draw_rect(Rect2(x_offset, y_offset, fill_w, bar_height), fill_color, true)
