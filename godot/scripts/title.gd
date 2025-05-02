extends Control

@onready var assetRecognition = AssetRecognition.new()

@onready var titleLabel = $TitleLabel
@onready var background = $Background
@onready var logoPanel = $LogoPanel
@onready var music_player = $MusicPlayer
@onready var button_container = $ButtonContainer

@onready var options = $Options

const IMG_PATH = "res://Public/Img/"
const BACKGROUND = "background"
const LOGO = "logo"
const MUSIC_PATH = "res://Public/Music/titleTheme.ogg"
const CONFIG_FILE = "res://config/settings.cfg"

var project_name = ProjectSettings.get("application/config/name") # Modificar si se quiere cambiar el nombre del juego

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
	titleLabel.text = project_name
	
	# Carga recursos visuales
	assetRecognition.load_visual_resource(IMG_PATH, BACKGROUND, background)
	assetRecognition.load_visual_resource(IMG_PATH, LOGO, logoPanel)
	
	# Carga música título
	if FileAccess.file_exists(MUSIC_PATH):
		var music = load(MUSIC_PATH)
		music_player.stream = music
		music_player.stream.loop = true
	music_player.play()
	
	# Carga botones
	for button in button_container.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))

func _on_button_pressed(button_name):
	match button_name:
		"PlayButton":
			get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
		"OptionsButton":
			options.visible = true
		"ExitButton":
			get_tree().quit()

func _on_close_options():
	options.visible = false
