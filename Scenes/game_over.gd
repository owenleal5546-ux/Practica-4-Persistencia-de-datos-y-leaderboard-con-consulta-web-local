extends Control

@onready var retry_button = $MarginContainer/VBoxContainer/RetryButton
@onready var main_menu_button = $MarginContainer/VBoxContainer/MainMenuButton

func _ready() -> void:
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)

func _get_world_path() -> String:
	if ResourceLoader.exists("res://Scenes/World.tscn"):
		return "res://Scenes/World.tscn"
	return "res://World/world.tscn"

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file(_get_world_path())

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
