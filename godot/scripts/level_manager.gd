extends Node

signal minigame_result(win: bool)

@onready var assetRecognition = AssetRecognition.new()

@onready var UIContainer = $UIContainer
@onready var videoPlayer = $UIContainer/VideoStreamPlayer
@onready var popup_container = $UIContainer/PopupContainer
@onready var popup_label = $UIContainer/PopupContainer/PopupLabel
@onready var health_container = $UIContainer/HealthContainer
@onready var score_label = $UIContainer/ScoreLabel
@onready var minigame_container = $MinigameContainer
@onready var minigame_timer = $Timer
@onready var timeLabel = $TimeLabel
@onready var options = $Options
@onready var post_process_material = $shaderEffects.material

@onready var music_manager = get_tree().get_root().get_node("MusicManager")

var level_index = "Level1"
var minigames_list = []
var minigame_index : int = 0

const MAX_LIVES = 1
const MAX_SCORE = 4
const SPEED_UP_SCORE = 2
const MAX_TEMPO = 0.5

var lives = MAX_LIVES
var score = 0
var tempo = 0
var minigame_duration = 5

var current_level_path = Globals.LEVELS_PATH + "/" + level_index + "/"
var video_intro
var video_control
var video_lose
var video_win_end
var video_lose_end
var popup # el popup de instrucciones lo gestiona el usuario con el nombre dado en el info.json
var minigame_info_path

var levelTheme

var win = true

enum State { CONTROL, GAME, END }

func _ready():
	# Cargar paths
	video_intro = load(current_level_path + Globals.INTRO_VID + ".ogv")
	video_control = load(current_level_path + Globals.CONTROL_VID + ".ogv")
	video_lose = load(current_level_path + Globals.LOSE_VID + ".ogv")
	video_win_end = load(current_level_path + Globals.WIN_END_VID + ".ogv")
	video_lose_end = load(current_level_path + Globals.LOSE_END_VID + ".ogv")
	# POPUP file must be the same as defined on the info.json
	
	levelTheme = load(current_level_path + Globals.LEVEL_THEME + ".ogg")
	
	minigame_timer.connect("timeout", Callable(self, "_on_time_up"))
	options.close_options.connect(_on_close_options)
	options.open_options.connect(_on_open_options)
	# Cargar música
	if !music_manager:
		music_manager = preload(Globals.MUSIC_MANAGER_SCENE).instantiate()
		get_tree().get_root().call_deferred("add_child", music_manager)
		await get_tree().process_frame
	
	# Cargar popup
	popup_container.visible = false
	popup_label.text = "nose"
	
	# Cargar vidas+puntuacion
	health_container.visible = false
	for health in health_container.get_children():
		assetRecognition.load_visual_resource(current_level_path, Globals.HEALTH_SPRITE, health.get_child(0))
	score_label.visible = false
	score_label.text = str(score)
	
	# Cargar lista de minijuegos en el nivel
	assetRecognition.load_names_from_directory(Globals.LEVELS_PATH + "/" + str(level_index), minigames_list)
	print(minigames_list)
	
	# Cargar cinemática intro
	introduction_scene()

func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
	post_process_material.set_shader_parameter("time", t)

func introduction_scene():
	videoPlayer.stream = video_intro
	videoPlayer.play()
	await videoPlayer.finished
	videoPlayer.stop()
	# Cargar música general del nivel
	music_manager.play_music(levelTheme)
	main_iteration(State.CONTROL)

func main_iteration(state : State):
	match state:
		State.CONTROL:
			#if !music_manager.music.playing:
				#music_manager.play_music(load(Globals.MUSIC_PATH + Globals.LEVEL_THEME + ".ogg"))
			# Lógica de selección de nivel aleatorio
			minigame_index = 0
			minigame_info_path = current_level_path + minigames_list[minigame_index] + "/" + Globals.MINIGAME_INFO + ".json"
			
			# Vídeo fondo escena control (win/lose)
			if win:
				videoPlayer.stream = video_control
			if !win:
				videoPlayer.stream = video_lose
			videoPlayer.play()
			
			# Sprites escena de control
			health_container.visible = true
			score_label.visible = true
			
			# Popup y lógica del speed up
			if !(score % SPEED_UP_SCORE) and score != 0:
				assetRecognition.load_visual_resource(current_level_path, Globals.SPEED_UP_POPUP, popup_container)
				popup_container.visible = true
				music_manager.music.pitch_scale = 1.1
				tempo = tempo + 0.1 # podríamos poner un sonido (seta de mario creciendo) y cuando acabe (en vez de la espera) aumentamos el pitch (también habría que pausar la música)
				await get_tree().create_timer(1, false).timeout
				popup_container.visible = false
			
			# Visualización normal
			await get_tree().create_timer(1, false).timeout
			
		#var path = minigame_info
		#var file = FileAccess.open(minigame_info, FileAccess.READ)
		#if file:
			#var data = JSON.parse_string(file.get_as_text())
		#if data == null:
			#push_error("ERROR: JSON read fail ", path)
		#container.text = data[JSONelement]
		
			# Popup de instructions
			print(minigame_info_path)
			popup = assetRecognition.get_json_element(minigame_info_path, "instruction") # Obtener el nombre de la instrucción del nivel escogido
			assetRecognition.load_visual_resource(current_level_path, popup, popup_container)
			popup_container.visible = true
			await get_tree().create_timer(1, false).timeout
			popup_container.visible = false
			
			videoPlayer.stop()
			health_container.visible = false
			score_label.visible = false
			main_iteration(State.GAME)
		State.GAME:
			var minigame = load("res://Levels/Level1/" + minigames_list[minigame_index] + "/Game.tscn").instantiate()
			minigame.win.connect(Callable(self, "_on_minigame_result"))
			minigame_container.add_child(minigame)
			minigame_timer.wait_time = minigame_duration - minigame_duration*tempo
			minigame_timer.start()
			_run_timer_feedback()
			win = await self.minigame_result
			for child in minigame_container.get_children():
				child.queue_free()
			if win:
				score = score+1
				score_label.text = str(score)
				if score >= MAX_SCORE:
					main_iteration(State.END)
					return
			else:
				lives = lives-1
				health_container.get_child(lives).get_child(0).visible = false
				if lives <= 0:
					main_iteration(State.END)
					return
			main_iteration(State.CONTROL)
		State.END:
			if win:
				videoPlayer.stream = video_win_end
			else:
				videoPlayer.stream = video_lose_end
			videoPlayer.play()
			await get_tree().create_timer(1, false).timeout
			# Antes de volver al menú, pasar por una escena épica de victoria (video hasta que acabe)
			music_manager.music.pitch_scale = 1
			music_manager.stop_music()
			var transition = preload(Globals.SCENE_TRANSITION_SCENE).instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene(preload(Globals.MAIN_MENU_SCENE).instantiate())

func _run_timer_feedback():
	while minigame_timer.time_left > 0:
		timeLabel.text = str(round(minigame_timer.time_left))
		await get_tree().create_timer(0.1).timeout
	timeLabel.text = ""

func _on_time_up():
	emit_signal("minigame_result", false)

func _on_minigame_result(win: bool):
	minigame_timer.stop()
	emit_signal("minigame_result", win)

func _on_close_options():
	get_tree().paused = false

func _on_open_options():
	get_tree().paused = true

func set_level_index(index):
	level_index = index
