extends Control

@onready var assetRecognition = AssetRecognition.new()

@onready var background = $Background
@onready var level_picture = $LevelPicturePanel/LevelPicture
@onready var level_label = $LevelLabel
@onready var button_control = $ButtonControl
@onready var options = $Options
@onready var label1 = $DescriptionPanel/VBoxContainer/MarginContainer/Label
@onready var label2 = $DescriptionPanel/VBoxContainer/MarginContainer2/Label2
@onready var label3 = $DescriptionPanel/VBoxContainer/MarginContainer3/RichTextLabel
@onready var music_player = $MusicPlayer

@onready var music_manager = get_tree().get_root().get_node("MusicManager")

const IMG_PATH = "res://Public/Img/"
const BACKGROUND = "mainMenuBg"
const LEVEL_PICTURE = "picture"
const LEVEL_INFO = "info.json"
const LEVELS_PATH = "res://Levels"
const MUSIC_PATH = "res://Public/Music/pizza.ogg"

var levels = []
var current_index = 0

func _ready():
	options.close_options.connect(_on_close_options)
	
	# Cargar los niveles (array levels)
	assetRecognition.load_levels_from_directory(LEVELS_PATH, levels)
	
	# Cargar elementos visuales
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
	assetRecognition.load_json_resource(current, LEVEL_INFO, level_label, "nombre")
	assetRecognition.load_json_resource(current, LEVEL_INFO, label1, "puntuacion")
	assetRecognition.load_json_resource(current, LEVEL_INFO, label2, "superado")
	assetRecognition.load_json_resource(current, LEVEL_INFO, label3, "descripcion")

func _on_button_pressed(button_name):
	match button_name:
		"OptionsButton":
			show_options()
		"PlayButton":
			get_tree().change_scene_to_file("res://scenes/levelManager.tscn")
			#get_tree().change_scene_to_file(LEVELS_PATH + "/" + levels[current_index] + "/" + "sinewave.tscn") # Por aquí hay que tirar después de acabar completamente con el menu
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
