extends Node

signal minigame_result(win: bool)

@onready var assetRecognition = AssetRecognition.new()
@onready var saveEncoder = SaveEncoder.new()
@onready var music_manager = get_tree().get_root().get_node("MusicManager")

@onready var video_player = $UIContainer/VideoStreamPlayer
@onready var popup_container = $UIContainer/PopupContainer
@onready var health_container = $UIContainer/HealthContainer
@onready var score_label = $UIContainer/ScoreLabel
@onready var minigame_container = $MinigameContainer
@onready var minigame_timer = $Timer
@onready var time_label = $TimeIndicatorContainer/TimeIndicatorLabel
@onready var time_sprite = $TimeIndicatorContainer/TimeIndicatorSpriteContainer
@onready var options = $Options
@onready var post_process_material = $shaderEffects.material

const MAX_LIVES = 2 # MAX 9 (else it overflows)
const MAX_SCORE = 2
const SPEED_UP_SCORE = 2
const MIN_MINIGAME_DURATION = 2.0
var lives = MAX_LIVES if MAX_LIVES < 9 else 9
var score = 0
var win : bool = true

var endless_mode : bool = false
var level_index : String = "Level1"
var current_level_path = Globals.LEVELS_PATH + level_index + "/"

var minigames_list = []
var minigames_path = current_level_path + Globals.MINIGAMES_DIR
var prev_minigame_index = -1
var minigame_index = -1
var minigame

var video_intro
var video_control
var video_lose
var video_win_end
var video_lose_end
var levelTheme
var popup
var minigame_info_path

enum State { CONTROL, GAME, END }

func _ready():
	video_intro = load(current_level_path + Globals.INTRO_VID + Globals.VIDEO_EXT)
	video_control = load(current_level_path + Globals.CONTROL_VID + Globals.VIDEO_EXT)
	video_lose = load(current_level_path + Globals.LOSE_VID + Globals.VIDEO_EXT)
	video_win_end = load(current_level_path + Globals.WIN_END_VID + Globals.VIDEO_EXT)
	video_lose_end = load(current_level_path + Globals.LOSE_END_VID + Globals.VIDEO_EXT)
	levelTheme = load(current_level_path + Globals.LEVEL_THEME + "." + assetRecognition.get_extension(current_level_path, Globals.LEVEL_THEME))
	
	options.show_exit_button(true)
	options.close_options.connect(_on_close_options)
	options.open_options.connect(_on_open_options)
	options.connect("exit_to_main_menu", Callable(self, "_on_exit_requested"))
	
	if !music_manager:
		music_manager = preload(Globals.MUSIC_MANAGER_SCENE).instantiate()
		get_tree().get_root().call_deferred("add_child", music_manager)
		await get_tree().process_frame
	
	popup_container.visible = false
	health_container.visible = false
	for i in MAX_LIVES:
		if i < 9: # Control that the lives don't overflow
			var healt_margin_container = MarginContainer.new()
			healt_margin_container.custom_minimum_size = Vector2(125, 125)
			health_container.add_child(healt_margin_container)
			assetRecognition.load_visual_resource(current_level_path, "speed_up", healt_margin_container)
	score_label.visible = false
	score_label.text = str(score)
	
	current_level_path = Globals.LEVELS_PATH + level_index + "/"
	minigames_path = current_level_path + Globals.MINIGAMES_DIR
	assetRecognition.load_dir_names_from_directory(minigames_path, minigames_list)
	
	# Cargar cinemática intro
	#introduction_scene()
	music_manager.play_music(levelTheme)
	main_iteration(State.CONTROL)

func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
	post_process_material.set_shader_parameter("time", t)

func introduction_scene():
	video_player.stream = video_intro
	video_player.play()
	await video_player.finished
	video_player.stop()
	# Cargar música general del nivel
	music_manager.play_music(levelTheme)
	main_iteration(State.CONTROL)

func choose_next_minigame_index() -> int:
	if minigames_list.size() <= 1:
		return 0  # No hay forma de evitar la repetición

	var new_index := randi() % minigames_list.size()
	while new_index == prev_minigame_index:
		new_index = randi() % minigames_list.size()

	prev_minigame_index = new_index
	return new_index

func main_iteration(state : State):
	match state:
		State.CONTROL:
			#if !music_manager.music.playing:
				#music_manager.play_music(load(Globals.MUSIC_PATH + Globals.LEVEL_THEME + ".ogg"))
			# Lógica de selección de nivel aleatorio
			minigame_index = choose_next_minigame_index()
			minigame_info_path = minigames_path + minigames_list[minigame_index] + "/" + Globals.MINIGAME_INFO + ".json"
			
			# Vídeo fondo escena control (win/lose)
			if win:
				video_player.stream = video_control
			if !win:
				video_player.stream = video_lose
			video_player.play()
			
			# Sprites escena de control
			health_container.visible = true
			score_label.visible = true
			
			# Popup y lógica del speed up
			if !(score % SPEED_UP_SCORE) and score != 0 and music_manager.music.pitch_scale < 2:
				assetRecognition.load_visual_resource(current_level_path, Globals.SPEED_UP_POPUP, popup_container, TextureRect.EXPAND_FIT_HEIGHT)
				popup_container.visible = true
				music_manager.music.pitch_scale = music_manager.music.pitch_scale + 0.1 # podríamos poner un sonido (seta de mario creciendo) y cuando acabe (en vez de la espera) aumentamos el pitch (también habría que pausar la música)
				await get_tree().create_timer(1, false).timeout
				popup_container.visible = false
				popup_container.get_child(0).queue_free()
			
			# Visualización normal
			await get_tree().create_timer(1, false).timeout
			
			# Popup de instructions
			popup = assetRecognition.get_json_element(minigame_info_path, "instruction") # Obtener el nombre de la instrucción del nivel escogido
			assetRecognition.load_visual_resource(current_level_path, popup, popup_container, TextureRect.EXPAND_FIT_HEIGHT)
			popup_container.visible = true
			await get_tree().create_timer(1, false).timeout
			popup_container.visible = false
			popup_container.get_child(0).queue_free()
			
			video_player.stop()
			health_container.visible = false
			score_label.visible = false
			main_iteration(State.GAME)
		State.GAME:
			win = assetRecognition.get_json_element(minigame_info_path, "survival") == "true"
			minigame = load(minigames_path + minigames_list[minigame_index] + "/Game.tscn").instantiate()
			minigame.win.connect(Callable(self, "_on_minigame_result"))
			minigame_container.add_child(minigame)
			
			# Asignar tiempo del minijuego al contador (controlar por si algún loco mete que el tiempo sea inferior a 2 segundos)
			var min_time = assetRecognition.get_json_element(minigame_info_path, "duration")
			if min_time >= MIN_MINIGAME_DURATION:
				minigame_timer.wait_time = min_time
			elif min_time < MIN_MINIGAME_DURATION:
				minigame_timer.wait_time = MIN_MINIGAME_DURATION
			
			minigame_timer.start()
			_run_timer_feedback()
			await minigame_timer.timeout
			for child in minigame_container.get_children():
				child.queue_free()
			if win:
				score = score+1
				score_label.text = str(score)
				if score >= MAX_SCORE and !endless_mode:
					main_iteration(State.END)
					return
			else:
				lives = lives-1
				health_container.get_child(lives).free()
				if lives <= 0:
					main_iteration(State.END)
					return
			main_iteration(State.CONTROL)
		State.END:
			if win:
				video_player.stream = video_win_end
				# Guardar que el juego ha sido completado y la calidad (si ha perdido vidas 0: S, 1: A, 2: B, 3: C)
				var quality = "C"
				match lives:
					1: quality = "C"
					2: quality = "B"
					3: quality = "A"
					4: quality = "S"
				update_level_info(Globals.DATA_FILE, level_index, "score", quality)
			else:
				video_player.stream = video_lose_end
				# Guardar los datos de la puntuación en caso de que el nivel no estuviera completado antes
				if endless_mode: # <leer "endless_score": 4>:
					update_level_info(Globals.DATA_FILE, level_index, "endless_score", score)
			video_player.play()
			# await video_player.finished
			await get_tree().create_timer(1, false).timeout
			music_manager.music.pitch_scale = 1
			music_manager.stop_music()
			var transition = preload(Globals.SCENE_TRANSITION_SCENE).instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene(preload(Globals.MAIN_MENU_SCENE).instantiate())

func update_level_info(data_path: String, level_key: String, field: String, mode_score):
	var score_rank = { "S": 4, "A": 3, "B": 2, "C": 1 }

	# Leer datos con verificación de integridad
	var json_data: Dictionary = saveEncoder.load_encoded_json(data_path)

	# Asegurar que el nivel existe
	if not json_data.has(level_key):
		json_data[level_key] = {}

	var level_data = json_data[level_key]

	# Actualizar campos
	if field == "score":
		var current_score = str(level_data.get("score", "C"))
		if score_rank.has(current_score) and score_rank.has(mode_score):
			if score_rank[mode_score] > score_rank[current_score]:
				level_data["score"] = mode_score
				level_data["complete"] = true
	elif field == "endless_score":
		level_data["endless_score"] = mode_score

	# Guardar de vuelta con codificación
	json_data[level_key] = level_data
	saveEncoder.save_encoded_json(data_path, json_data)


func _run_timer_feedback():
	var animation_activa = false
	time_label.visible = true
	while minigame_timer.time_left > 0:
		time_label.text = str(minigame_timer.time_left)
		if minigame_timer.time_left <= MIN_MINIGAME_DURATION and !animation_activa:
			_run_clock_animation()
			animation_activa = true
		
		await get_tree().create_timer(0.1, false).timeout
	time_label.visible = false

func _run_clock_animation():
	time_sprite.visible = true
	var clocks_list = []
	assetRecognition.load_file_names_from_directory(current_level_path + "Clock", clocks_list)
	var tiempo_frame : float = minigame_timer.time_left/clocks_list.size() - 0.05
	for clock in clocks_list:
		assetRecognition.load_visual_resource(current_level_path + "Clock/", clock, time_sprite, TextureRect.EXPAND_IGNORE_SIZE, TextureRect.STRETCH_KEEP_ASPECT)
		await get_tree().create_timer(tiempo_frame, false).timeout
		time_sprite.get_child(0).queue_free()
	
	time_sprite.visible = false

func _on_minigame_result(win_signal: bool):
	self.win = win_signal
	if minigame_timer.time_left > 2:
		minigame_timer.start(2) # En vez de detener el timer, pone los dos segundos de cronómetro y la señal que desactiva la espera es la del timer (ver cómo mandarle el dato win)
	_set_paused_recursively(minigame_container.get_child(0), true) 

func _set_paused_recursively(node: Node, paused: bool) -> void:
	node.set_process(not paused)
	node.set_physics_process(not paused)
	node.set_process_input(not paused)
	node.set_process_unhandled_input(not paused)
	node.set_process_unhandled_key_input(not paused)
	for child in node.get_children():
		if child is Node:
			_set_paused_recursively(child, paused)

func _on_close_options():
	get_tree().paused = false

func _on_open_options():
	get_tree().paused = true

func _on_exit_requested():
	music_manager.music.pitch_scale = 1
	music_manager.stop_music()
	var transition = preload(Globals.SCENE_TRANSITION_SCENE).instantiate()
	get_tree().root.add_child(transition)
	transition.change_scene(preload(Globals.MAIN_MENU_SCENE).instantiate())

func set_level_index(index):
	level_index = index
	
func set_endless(endless: bool):
	endless_mode = endless
