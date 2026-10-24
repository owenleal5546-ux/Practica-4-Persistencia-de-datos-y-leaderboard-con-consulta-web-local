extends Control

@onready var play_button = $MarginContainer/VBoxContainer/PlayButton
@onready var level2_button = $MarginContainer/VBoxContainer/Level2Button
@onready var quit_button = $MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if level2_button:
		level2_button.pressed.connect(_on_level2_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _get_world_path() -> String:
	if ResourceLoader.exists("res://Scenes/World.tscn"):
		return "res://Scenes/World.tscn"
	return "res://World/world.tscn"

func _on_play_pressed() -> void:
	if GameManager:
		GameManager.reset_score()
	get_tree().change_scene_to_file(_get_world_path())

func _on_level2_pressed() -> void:
	if GameManager:
		GameManager.reset_score()
	get_tree().change_scene_to_file("res://Scenes/Nivel2.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
