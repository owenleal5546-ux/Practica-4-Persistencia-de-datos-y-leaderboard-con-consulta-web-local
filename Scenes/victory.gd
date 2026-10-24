extends Control

@onready var next_level_button = $MarginContainer/VBoxContainer/ButtonsHBox/NextLevelButton
@onready var main_menu_button = $MarginContainer/VBoxContainer/ButtonsHBox/MainMenuButton
@onready var stats_label = $MarginContainer/VBoxContainer/StatsPanel/VBox/StatsLabel
@onready var history_button = $MarginContainer/VBoxContainer/HistoryButton
@onready var history_panel = $MarginContainer/VBoxContainer/HistoryPanel
@onready var history_text = $MarginContainer/VBoxContainer/HistoryPanel/HistoryText

func _ready() -> void:
	if next_level_button:
		next_level_button.pressed.connect(_on_next_level_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	if history_button:
		history_button.pressed.connect(_on_history_button_pressed)
		
	_display_session_stats()

func _display_session_stats() -> void:
	var db = get_node_or_null("/root/DatabaseManager")
	if not db:
		if stats_label:
			stats_label.text = "Base de datos no disponible"
		return
		
	var session = db.get_last_session()
	if session.is_empty():
		if stats_label:
			stats_label.text = "No se encontraron sesiones registradas."
		return
		
	var s_id = session.get("id", "?")
	var s_usuario = session.get("usuario", "Jugador Principal")
	var s_nivel = session.get("nivel", "Nivel 1")
	var s_tiempo = session.get("tiempo_transcurrido", 0.0)
	var s_monedas = session.get("monedas_recolectadas", 0)
	var s_fecha = session.get("fecha", "")
	var s_tiempo_str = db.format_time(float(s_tiempo))
	
	if stats_label:
		stats_label.text = "Jugador: %s  |  Sesión: #%s\nNivel: %s\nTiempo: %s (%.2f s)\nMonedas recolectadas: %d\nFecha: %s" % [
			str(s_usuario), str(s_id), str(s_nivel), s_tiempo_str, float(s_tiempo), int(s_monedas), str(s_fecha)
		]

func _on_history_button_pressed() -> void:
	if not history_panel:
		return
	history_panel.visible = not history_panel.visible
	if history_panel.visible:
		_load_history()

func _load_history() -> void:
	var db = get_node_or_null("/root/DatabaseManager")
	if not db or not history_text:
		return
	var sessions = db.get_all_sessions(5)
	if sessions.is_empty():
		history_text.text = "Sin registros previos."
		return
	var text_lines: Array[String] = []
	for s in sessions:
		text_lines.append("#%s | %s | %s | %.2fs | 🪙 %d | 📅 %s" % [
			str(s.get("id")),
			str(s.get("usuario", "Jugador")),
			str(s.get("nivel")),
			float(s.get("tiempo_transcurrido", 0.0)),
			int(s.get("monedas_recolectadas", 0)),
			str(s.get("fecha"))
		])
	history_text.text = "\n".join(text_lines)

func _on_next_level_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Nivel2.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
