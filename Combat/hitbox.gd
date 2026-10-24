class_name Hitbox
extends Area2D

@export var damage: int = 1
@export var knockback_force: float = 120.0

func _init() -> void:
	monitoring = true
