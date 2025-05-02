extends Control

@onready var assetRecognition = AssetRecognition.new()

@onready var titleLabel = $TitleLabel
@onready var background = $Background
@onready var logoPanel = $LogoPanel
@onready var music_player = $MusicPlayer
@onready var button_container = $ButtonContainer

@onready var options = $Options

const CONFIG_FILE = "res://config/settings.cfg"
const IMG_PATH = "res://Public/Img/"
const BACKGROUND = "background"
const LOGO = "logo"
const MUSIC_PATH = "res://Public/Music/"
const TITLE_THEME = "titleTheme"

func _ready():
	# Carga los ajustes guardados
	var config = ConfigFile.new()
	if config.load(CONFIG_FILE) == OK:
		var fullscreen = config.get_value("video", "fullscreen", false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		var volume = config.get_value("audio", "music_volume", 0.5)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume))
	
	options.close_options.connect(_on_close_options)
	
	# Carga título juego
	titleLabel.text = ProjectSettings.get("application/config/name")
	
	# Carga recursos visuales
	assetRecognition.load_visual_resource(IMG_PATH, BACKGROUND, background)
	assetRecognition.load_visual_resource(IMG_PATH, LOGO, logoPanel)
	
	# Carga música título
	assetRecognition.load_audio_resource(MUSIC_PATH, TITLE_THEME, music_player)
	
	# Carga botones
	for button in button_container.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))

func _on_button_pressed(button_name):
	match button_name:
		"PlayButton":
			var transition = preload("res://scenes/sceneTransition.tscn").instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene("res://scenes/mainMenu.tscn")
		"OptionsButton":
			options.visible = true
		"ExitButton":
			get_tree().quit()

func _on_close_options():
	options.visible = false
