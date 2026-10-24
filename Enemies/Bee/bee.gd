extends CharacterBody2D

const DeathEffectScene = preload("res://VFX/enemy_death_effect.tscn")
const BloodSplatterScene = preload("res://VFX/blood_splatter.tscn")

@export var max_health: int = 1
@export var hover_speed: float = 3.0
@export var hover_distance: float = 10.0

var current_health: int = 1
var is_dead: bool = false
var _initial_y: float = 0.0
var _time_passed: float = 0.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox

func _ready() -> void:
	_initial_y = position.y
	current_health = max_health
	if health_bar:
		health_bar.setup(max_health, current_health)
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit_received)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_time_passed += delta
	position.y = _initial_y + sin(_time_passed * hover_speed) * hover_distance

func _on_hit_received(damage: int, attacker_pos: Vector2, knockback: float) -> void:
	if is_dead:
		return
	take_damage(damage, attacker_pos, knockback)

func take_damage(amount: int, attacker_pos: Vector2 = Vector2.ZERO, knockback: float = 40.0) -> void:
	if is_dead:
		return
	current_health -= amount
	if health_bar:
		health_bar.update_health(current_health, max_health)

	_flash_damage()

	var blood = BloodSplatterScene.instantiate()
	blood.global_position = global_position
	get_parent().add_child(blood)
	var blood_dir = (global_position - attacker_pos).normalized() if attacker_pos != Vector2.ZERO else Vector2(0, -1)
	blood.setup(blood_dir, false)

	if current_health <= 0:
		die()

func _flash_damage() -> void:
	var tween = create_tween()
	animated_sprite_2d.modulate = Color(3.0, 0.4, 0.4, 1.0)
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.15)

func die() -> void:
	is_dead = true
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)

	var death_fx = DeathEffectScene.instantiate()
	death_fx.global_position = global_position
	get_parent().add_child(death_fx)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)
