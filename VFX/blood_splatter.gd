class_name BloodSplatter
extends Node2D

const BloodDecalScene = preload("res://VFX/blood_decal.tscn")

@onready var particles: CPUParticles2D = $CPUParticles2D

var _droplets: Array[Dictionary] = []
var _time_alive: float = 0.0
var _max_lifetime: float = 1.0

func setup(impact_direction: Vector2, spawn_decals: bool = true) -> void:
	if impact_direction.length_squared() < 0.001:
		impact_direction = Vector2(0, -1)
	else:
		impact_direction = impact_direction.normalized()

	if not particles:
		particles = $CPUParticles2D

	if particles:
		particles.direction = impact_direction
		particles.restart()
		particles.emitting = true

	if spawn_decals:
		_init_droplets(impact_direction)

func _ready() -> void:
	if not particles:
		particles = $CPUParticles2D
	particles.emitting = true

func _init_droplets(base_dir: Vector2) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var count = rng.randi_range(4, 7)
	for i in range(count):
		var angle_offset = rng.randf_range(-deg_to_rad(35), deg_to_rad(35))
		var dir = base_dir.rotated(angle_offset)
		dir.y -= rng.randf_range(0.2, 0.5)
		dir = dir.normalized()
		var speed = rng.randf_range(60.0, 140.0)
		_droplets.append({
			"pos": global_position,
			"vel": dir * speed,
			"alive": true
		})

func _physics_process(delta: float) -> void:
	_time_alive += delta
	var space_state = get_world_2d().direct_space_state
	var any_alive = false

	for droplet in _droplets:
		if not droplet["alive"]:
			continue
		any_alive = true
		var current_pos: Vector2 = droplet["pos"]
		droplet["vel"].y += 350.0 * delta
		var next_pos: Vector2 = current_pos + droplet["vel"] * delta

		var query = PhysicsRayQueryParameters2D.create(current_pos, next_pos, 1)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		var result = space_state.intersect_ray(query)

		if result:
			droplet["alive"] = false
			_spawn_decal(result.position, result.normal)
		else:
			droplet["pos"] = next_pos

	if _time_alive >= _max_lifetime and not any_alive:
		queue_free()

func _spawn_decal(pos: Vector2, normal: Vector2) -> void:
	var decal = BloodDecalScene.instantiate()
	decal.global_position = pos + normal * 0.5
	var level = get_tree().current_scene
	if level:
		level.add_child(decal)
	else:
		get_parent().add_child(decal)
