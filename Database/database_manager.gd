extends Node

## DatabaseManager
## Administrador de Base de Datos SQLite para Sunny Land Forest
## Gestiona la conexión a SQLite, tablas relacionales e inserción de sesiones de juego.

signal session_saved(session_data: Dictionary)

const DB_FILE_PATH: String = "user://game_database.db"

var db: SQLite = null
var is_initialized: bool = false

# Variables de seguimiento de la sesión actual
var active_user_id: int = 1
var current_level_name: String = "Nivel 1"
var level_start_ticks: int = 0
var level_coins_collected: int = 0
var is_tracking: bool = false
var last_saved_session: Dictionary = {}

func _ready() -> void:
	init_database()

## Inicializa la base de datos SQLite y crea el esquema relacional
func init_database() -> void:
	if is_initialized:
		return
		
	db = SQLite.new()
	db.path = DB_FILE_PATH
	db.foreign_keys = true
	
	if not db.open_db():
		printerr("[DatabaseManager] Error al abrir la base de datos SQLite en: ", DB_FILE_PATH)
		return
		
	# Habilitar claves foráneas
	db.query("PRAGMA foreign_keys = ON;")
	
	# 1. Tabla de usuarios/jugadores (Padre en la relación)
	var sql_users = """
	CREATE TABLE IF NOT EXISTS usuarios (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nombre TEXT NOT NULL UNIQUE,
		fecha_creacion TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
	);
	"""
	db.query(sql_users)
	
	# 2. Tabla relacional de sesiones de juego (Hija con clave foránea a usuarios)
	# Campos solicitados: ID, tiempo transcurrido, monedas recolectadas, nivel y fecha
	var sql_sessions = """
	CREATE TABLE IF NOT EXISTS sesiones_juego (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		usuario_id INTEGER NOT NULL DEFAULT 1,
		tiempo_transcurrido REAL NOT NULL,
		monedas_recolectadas INTEGER NOT NULL,
		nivel TEXT NOT NULL,
		fecha TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
		FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
	);
	"""
	db.query(sql_sessions)
	
	# Asegurar usuario por defecto para las sesiones
	db.query("INSERT OR IGNORE INTO usuarios (id, nombre) VALUES (1, 'Jugador Principal');")
	
	is_initialized = true
	var real_path = ProjectSettings.globalize_path(DB_FILE_PATH)
	print("[DatabaseManager] Base de datos SQLite inicializada exitosamente.")
	print("[DatabaseManager] Ubicación del archivo de base de datos: ", real_path)

## Inicia el cronómetro y conteo de monedas para un nivel
func start_level_tracking(level_name: String = "") -> void:
	if level_name != "":
		current_level_name = level_name
	level_start_ticks = Time.get_ticks_msec()
	level_coins_collected = 0
	is_tracking = true
	print("[DatabaseManager] Seguimiento iniciado para: '%s'" % current_level_name)

## Registra una moneda recolectada en la sesión activa
func record_coin() -> void:
	level_coins_collected += 1

## Obtiene el tiempo transcurrido en segundos desde el inicio del nivel
func get_elapsed_time() -> float:
	if not is_tracking or level_start_ticks == 0:
		return 0.0
	var now = Time.get_ticks_msec()
	return (now - level_start_ticks) / 1000.0

## Inserta una nueva sesión en la base de datos relacional
func insert_session(usuario_id: int, nivel: String, tiempo_transcurrido: float, monedas: int) -> Dictionary:
	if not is_initialized or db == null:
		init_database()
		
	# Redondear tiempo a 2 decimales
	var tiempo_redondeado: float = snappedf(tiempo_transcurrido, 0.01)
	
	var insert_sql = """
	INSERT INTO sesiones_juego (usuario_id, tiempo_transcurrido, monedas_recolectadas, nivel, fecha)
	VALUES (%d, %.2f, %d, '%s', datetime('now', 'localtime'));
	""" % [usuario_id, tiempo_redondeado, monedas, nivel.replace("'", "''")]
	
	var success = db.query(insert_sql)
	if not success:
		printerr("[DatabaseManager] Error al ejecutar inserción en sesiones_juego: ", db.error_message)
		return {}
		
	var new_id = db.get_last_insert_rowid()
	
	# Consultar el registro insertado con los datos relacionales
	var select_sql = """
	SELECT s.id, u.nombre AS usuario, s.nivel, s.tiempo_transcurrido, s.monedas_recolectadas, s.fecha
	FROM sesiones_juego s
	JOIN usuarios u ON s.usuario_id = u.id
	WHERE s.id = %d;
	""" % new_id
	
	db.query(select_sql)
	var session_data: Dictionary = {}
	if db.query_result.size() > 0:
		session_data = db.query_result[0]
	else:
		session_data = {
			"id": new_id,
			"usuario_id": usuario_id,
			"nivel": nivel,
			"tiempo_transcurrido": tiempo_redondeado,
			"monedas_recolectadas": monedas,
			"fecha": Time.get_datetime_string_from_system()
		}
		
	last_saved_session = session_data
	session_saved.emit(session_data)
	print("[DatabaseManager] ¡Sesión registrada con éxito! ID: #%s | Nivel: %s | Tiempo: %.2fs | Monedas: %d | Fecha: %s" % [
		session_data.get("id"),
		session_data.get("nivel"),
		session_data.get("tiempo_transcurrido"),
		session_data.get("monedas_recolectadas"),
		session_data.get("fecha")
	])
	return session_data

## Finaliza el nivel actual y guarda la sesión automáticamente
func finish_level_and_save(level_name: String = "", override_coins: int = -1) -> Dictionary:
	var final_level = level_name if level_name != "" else current_level_name
	var elapsed = get_elapsed_time()
	var coins = override_coins if override_coins >= 0 else level_coins_collected
	
	# Detener seguimiento
	is_tracking = false
	
	return insert_session(active_user_id, final_level, elapsed, coins)

## Obtiene todas las sesiones registradas con información del usuario
func get_all_sessions(limit: int = 50) -> Array:
	if not is_initialized or db == null:
		init_database()
		
	var sql = """
	SELECT s.id, u.nombre AS usuario, s.nivel, s.tiempo_transcurrido, s.monedas_recolectadas, s.fecha
	FROM sesiones_juego s
	JOIN usuarios u ON s.usuario_id = u.id
	ORDER BY s.id DESC
	LIMIT %d;
	""" % limit
	
	db.query(sql)
	return db.query_result.duplicate()

## Obtiene la última sesión guardada
func get_last_session() -> Dictionary:
	if not last_saved_session.is_empty():
		return last_saved_session
		
	var sessions = get_all_sessions(1)
	if sessions.size() > 0:
		last_saved_session = sessions[0]
		return last_saved_session
	return {}

## Formatea segundos a texto legible "MM:SS.ss"
static func format_time(seconds: float) -> String:
	var total_sec: int = int(seconds)
	var mins: int = total_sec / 60
	var secs: int = total_sec % 60
	var millis: int = int((seconds - total_sec) * 100)
	return "%02d:%02d.%02d" % [mins, secs, millis]

## Cierra la base de datos limpiamente
func close_database() -> void:
	if db and is_initialized:
		db.close_db()
		is_initialized = false

func _exit_tree() -> void:
	close_database()
