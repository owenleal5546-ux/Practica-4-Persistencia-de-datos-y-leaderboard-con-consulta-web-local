class_name Hurtbox
extends Area2D

const HitboxClass = preload("res://Combat/hitbox.gd")

signal hit_received(damage: int, attacker_position: Vector2, knockback: float)

@export var is_invulnerable: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxClass:
		take_hit(area)

func take_hit(hitbox: Area2D) -> void:
	if is_invulnerable:
		return
	var dmg: int = hitbox.get("damage") if "damage" in hitbox else 1
	var kb: float = hitbox.get("knockback_force") if "knockback_force" in hitbox else 100.0
	hit_received.emit(dmg, hitbox.global_position, kb)

func set_invulnerable(value: bool) -> void:
	is_invulnerable = value
