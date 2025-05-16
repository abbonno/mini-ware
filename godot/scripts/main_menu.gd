extends Control

@onready var assetRecognition = AssetRecognition.new()

@onready var background = $Background
@onready var level_picture = $LevelPicturePanel/LevelPicture
@onready var button_control = $ButtonControl
@onready var play_button = $ButtonControl/PlayButton
@onready var level_name = $LevelName
@onready var score = $LevelInfoPanel/LevelInfoContainer/ScoreLabelContainer/ScoreLabel
@onready var complete = $LevelInfoPanel/LevelInfoContainer/ScoreLabelContainer/ScoreLabel
@onready var description = $LevelInfoPanel/LevelInfoContainer/DescriptionLabelContainer/DescriptionLabel
@onready var options = $Options

@onready var music_manager = get_tree().get_root().get_node("MusicManager")

const IMG_PATH = "res://Public/Img/"
const BACKGROUND = "mainMenuBg"
const PLAY_ICON = "res://icon.svg"
const LEVEL_PICTURE = "picture"
const LEVEL_INFO = "info"
const LEVELS_PATH = "res://Levels"
const MUSIC_PATH = "res://Public/Music/mainMenuTheme.ogg"

var levels = []
var current_index = 0 # en el guardado de la información del juego almacenar el último nivel en el que se estuvo para comenzar desde ahí la próxima vez que se abra

func _ready():
	options.close_options.connect(_on_close_options)
	
	# Cargar los niveles (array levels)
	assetRecognition.load_levels_from_directory(LEVELS_PATH, levels)
	
	# Cargar elementos visuales
	play_button.icon = load(PLAY_ICON) # completar carga icono
	assetRecognition.load_visual_resource(IMG_PATH, BACKGROUND, background)
	
	# Cargar música
	if !music_manager:
		music_manager = preload("res://scenes/musicManager.tscn").instantiate()
		get_tree().get_root().call_deferred("add_child", music_manager)
		await get_tree().process_frame  # IMPORTANTE call deferred es una llamada asíncrona, por lo que si más tarde llamamos a play music no tendrá los nodos que necesita del árbol, es por eso que añadimos una espera (eS NECESARIA AQUÍ, PONERLA EN LA PROPIA FUNCIÓN DE REPRODUCCIÓN HARÁ QUE SE PRODUZCAN ESPERAS INFINITAS A LOS OTROS NODOS)
	music_manager.play_music(load(MUSIC_PATH))
	
	# Cargar botones
	for button in button_control.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))
	
	# Carga los elementos que dependen de "current_index"
	update_level_display()

func update_level_display():
	var current = LEVELS_PATH + "/" + levels[current_index] + "/"
	assetRecognition.load_visual_resource(current, LEVEL_PICTURE, level_picture)
	assetRecognition.load_json_resource(current, LEVEL_INFO, level_name, "level_name")
	assetRecognition.load_json_resource(current, LEVEL_INFO, score, "score")
	assetRecognition.load_json_resource(current, LEVEL_INFO, complete, "complete")
	assetRecognition.load_json_resource(current, LEVEL_INFO, description, "description")

func _on_button_pressed(button_name):
	match button_name:
		"OptionsButton":
			show_options()
		"PlayButton":
			music_manager.stop_music()
			var transition = preload("res://scenes/sceneTransition.tscn").instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene("res://scenes/levelManager.tscn")
		"ReturnButton":
			var transition = preload("res://scenes/sceneTransition.tscn").instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene("res://scenes/title.tscn")
		"NextLevelButton":
			current_index = (current_index + 1) % levels.size()
			update_level_display()
		"PrevLevelButton":
			current_index = (current_index - 1) % levels.size()
			update_level_display()

# Función para abrir las opciones
func show_options():
	options.visible = true

func _on_close_options():
	options.visible = false
