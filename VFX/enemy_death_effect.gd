class_name EnemyDeathEffect
extends Node2D

func _ready() -> void:
	$CPUParticles2D.emitting = true
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(queue_free)
