extends CharacterBody2D

const DeathEffectScene = preload("res://VFX/enemy_death_effect.tscn")
const BloodSplatterScene = preload("res://VFX/blood_splatter.tscn")

@export var max_health: int = 2
var current_health: int = 2

const SPEED = 20.0
var direction = 1
var is_dead = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var health_bar = $HealthBar
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox

func _ready() -> void:
	current_health = max_health
	if health_bar:
		health_bar.setup(max_health, current_health)
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit_received)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = move_toward(velocity.x, direction * SPEED, 200.0 * delta)

	move_and_slide()
	
	if ray_cast_2d and ray_cast_2d.is_colliding():
		direction *= -1
	
	if ray_cast_2d:
		ray_cast_2d.target_position.x = 20 * direction
	
	if direction > 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false

func _on_hit_received(damage: int, attacker_pos: Vector2, knockback: float) -> void:
	if is_dead:
		return
	take_damage(damage, attacker_pos, knockback)

func take_damage(amount: int, attacker_pos: Vector2 = Vector2.ZERO, knockback: float = 60.0) -> void:
	if is_dead:
		return
	current_health -= amount
	if health_bar:
		health_bar.update_health(current_health, max_health)

	_flash_damage()

	if attacker_pos != Vector2.ZERO:
		var push_dir = 1.0 if global_position.x > attacker_pos.x else -1.0
		velocity.x = push_dir * knockback

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
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)

	var death_fx = DeathEffectScene.instantiate()
	death_fx.global_position = global_position
	get_parent().add_child(death_fx)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)
