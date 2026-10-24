extends CharacterBody2D

const BloodSplatterScene = preload("res://VFX/blood_splatter.tscn")
const HurtboxClass = preload("res://Combat/hurtbox.gd")

const SPEED = 110.0
const JUMP_VELOCITY = -200.0

@export var max_health: int = 3
var current_health: int = 3
var is_invulnerable: bool = false
var is_hurt: bool = false
var is_dead: bool = false

var _invulnerable_timer: float = 0.0
var _hurt_timer: float = 0.0
var _attack_timer: float = 0.0
var facing_direction: int = 1

var gravity = 300

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var stomp_detector = $StompDetector
@onready var attack_hitbox = $AttackHitbox
@onready var hud = $PlayerHUD
@onready var camera_2d = $Camera2D

func _ready() -> void:
	current_health = max_health
	if hud:
		hud.setup(max_health, current_health)
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit_received)
	if attack_hitbox:
		attack_hitbox.monitoring = false
		attack_hitbox.monitorable = false
	if camera_2d:
		camera_2d.position = Vector2.ZERO
		camera_2d.offset = Vector2.ZERO
		camera_2d.zoom = Vector2(1.35, 1.35)
		camera_2d.limit_left = 0
		camera_2d.limit_top = -1000000
		camera_2d.limit_bottom = 1000000
		camera_2d.position_smoothing_enabled = true
		camera_2d.position_smoothing_speed = 6.0
		camera_2d.drag_horizontal_enabled = false
		camera_2d.drag_vertical_enabled = true
		camera_2d.drag_left_margin = 0.0
		camera_2d.drag_right_margin = 0.0
		camera_2d.drag_top_margin = 0.3
		camera_2d.drag_bottom_margin = 0.1
		_setup_camera_limits()

func _setup_camera_limits() -> void:
	if not camera_2d:
		return
	var tilemap = get_tree().current_scene.find_child("TileMap", true, false)
	if tilemap and tilemap is TileMap:
		var map_rect = tilemap.get_used_rect()
		var tile_size = tilemap.tile_set.tile_size
		var left_px = map_rect.position.x * tile_size.x
		var right_px = map_rect.end.x * tile_size.x
		
		camera_2d.limit_left = max(0, int(left_px))
		camera_2d.limit_right = int(right_px + 600)
		camera_2d.limit_top = -1000000
		camera_2d.limit_bottom = 1000000










func _physics_process(delta: float) -> void:
	_update_timers(delta)

	if is_dead:
		velocity.y += gravity * delta
		move_and_slide()
		return

	if global_position.y > 320 and not is_dead:
		die()
		return

	if is_hurt:
		velocity.y += gravity * delta
		animated_sprite_2d.play("hurt")
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Stomp on enemies while falling
	if velocity.y > 0:
		_check_stomp_enemies()

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Attack
	if Input.is_action_just_pressed("attack") and _attack_timer <= 0:
		_perform_attack()

	var input_axis = Input.get_axis("ui_left", "ui_right")
	if input_axis:
		velocity.x = input_axis * SPEED
		facing_direction = 1 if input_axis > 0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animations(input_axis)

func _update_timers(delta: float) -> void:
	if _hurt_timer > 0:
		_hurt_timer -= delta
		if _hurt_timer <= 0:
			is_hurt = false

	if is_invulnerable:
		_invulnerable_timer -= delta
		var blink = int(_invulnerable_timer * 18.0) % 2 == 0
		animated_sprite_2d.modulate.a = 0.35 if blink else 1.0
		if _invulnerable_timer <= 0:
			is_invulnerable = false
			animated_sprite_2d.modulate = Color.WHITE
			if hurtbox:
				hurtbox.set_invulnerable(false)

	if _attack_timer > 0:
		_attack_timer -= delta
		if _attack_timer <= 0 and attack_hitbox:
			attack_hitbox.monitoring = false
			attack_hitbox.monitorable = false

func _check_stomp_enemies() -> void:
	if not stomp_detector:
		return
	var areas = stomp_detector.get_overlapping_areas()
	for area in areas:
		if area is HurtboxClass:
			area.take_hit(stomp_detector)
			velocity.y = JUMP_VELOCITY * 0.9
			_stomp_feedback()
			break

func _stomp_feedback() -> void:
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "scale", Vector2(1.2, 0.8), 0.08)
	tween.tween_property(animated_sprite_2d, "scale", Vector2(1.0, 1.0), 0.08)

func _perform_attack() -> void:
	_attack_timer = 0.2
	if attack_hitbox:
		attack_hitbox.position.x = 12 * facing_direction
		attack_hitbox.monitoring = true
		attack_hitbox.monitorable = true
	var tween = create_tween()
	animated_sprite_2d.modulate = Color(1.8, 1.8, 1.8, 1.0)
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.12)

func _on_hit_received(damage: int, attacker_pos: Vector2, knockback: float) -> void:
	if is_invulnerable or is_dead:
		return
	take_damage(damage, attacker_pos, knockback)

func take_damage(amount: int, attacker_pos: Vector2 = Vector2.ZERO, knockback: float = 120.0) -> void:
	if is_invulnerable or is_dead:
		return

	current_health -= amount
	if hud:
		hud.update_health(current_health)

	_spawn_blood_vfx(attacker_pos)

	is_hurt = true
	_hurt_timer = 0.35
	is_invulnerable = true
	_invulnerable_timer = 1.2
	if hurtbox:
		hurtbox.set_invulnerable(true)

	var push_x = 1.0 if global_position.x >= attacker_pos.x else -1.0
	if attacker_pos == Vector2.ZERO:
		push_x = -facing_direction
	velocity = Vector2(push_x * knockback, -130.0)

	if current_health <= 0:
		die()

func _spawn_blood_vfx(attacker_pos: Vector2) -> void:
	var blood = BloodSplatterScene.instantiate()
	blood.global_position = global_position + Vector2(0, 4)
	var level = get_tree().current_scene
	if level:
		level.add_child(blood)
	else:
		get_parent().add_child(blood)

	var blood_dir: Vector2
	if attacker_pos != Vector2.ZERO:
		blood_dir = (global_position - attacker_pos).normalized()
	else:
		blood_dir = Vector2(-facing_direction, -0.7).normalized()

	blood.setup(blood_dir, true)

func die() -> void:
	is_dead = true
	is_hurt = false
	animated_sprite_2d.play("hurt")
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)

	_spawn_blood_vfx(global_position + Vector2(0, 10))

	set_collision_mask_value(1, false)
	velocity = Vector2(0, -160.0)

	var timer = get_tree().create_timer(1.4)
	timer.timeout.connect(func(): get_tree().change_scene_to_file("res://Scenes/GameOver.tscn"))

func update_animations(input_axis: float) -> void:
	if input_axis < 0:
		animated_sprite_2d.flip_h = true
	elif input_axis > 0:
		animated_sprite_2d.flip_h = false

	if is_on_floor():
		if input_axis != 0:
			animated_sprite_2d.play("skip")
		else:
			animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("jump")
