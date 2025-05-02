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

const IMG_PATH = "res://Public/Img/"
const BACKGROUND = "mainMenuBg"
const LEVEL_PICTURE = "picture"
const LEVEL_INFO = "info.json"
const LEVELS_PATH = "res://Levels"

var levels = []
var current_index = 0

func _ready():
	options.close_options.connect(_on_close_options)
	
	# Cargar los niveles (array levels)
	assetRecognition.load_levels_from_directory(LEVELS_PATH, levels)
	
	# Cargar elementos visuales
	assetRecognition.load_visual_resource(IMG_PATH, BACKGROUND, background)
	
	# Cargar música
	#assetRecognition.load_audio_resource()
	
	# Cargar botones
	for button in button_control.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))
	
	# Carga los elementos relacionados con el nivel mostrado
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
			get_tree().change_scene_to_file(LEVELS_PATH + "/" + levels[current_index] + "/" + "control.tscn")
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
