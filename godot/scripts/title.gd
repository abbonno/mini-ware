extends Control

@onready var title = $Title
@onready var music_player = $MusicPlayer
@onready var bg_texture = $Background
@onready var button_container = $ButtonContainer
@onready var options = $Options
@onready var titleLabel = $TitleLabel
@onready var logo = $Panel/Logo

const BACKGROUND_PATH = "res://Public/Img/background.jpg"
const LOGO_PATH = "res://Public/Img/logo.png"
const MUSIC_PATH = "res://Public/Music/titleTheme.ogg"
const BUTTON_TEXTURE = "res://Public/Img/buttonTextureNormal.png"

var project_name = ProjectSettings.get("application/config/name") # Modificar si se quiere cambiar el nombre del juego

func _ready():
	var config = ConfigFile.new()
	if config.load("res://config/settings.cfg") == OK:
		var fullscreen = config.get_value("video", "fullscreen", false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		var volume = config.get_value("audio", "music_volume", 0.5)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume))
	
	titleLabel.text = project_name
	options.visible = false
	options.close_options.connect(_on_close_options)
	if FileAccess.file_exists(LOGO_PATH):
		var texture = load(LOGO_PATH)
		logo.texture = texture
	if FileAccess.file_exists(BACKGROUND_PATH):
		var texture = load(BACKGROUND_PATH)
		bg_texture.texture = texture
	if FileAccess.file_exists(MUSIC_PATH):
		var music = load(MUSIC_PATH)
		music_player.stream = music

	music_player.play()
	
	for button in button_container.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))

func _on_button_pressed(button_name):
	print(button_name)
	match button_name:
		"PlayButton":
			start_game()
		"OptionsButton":
			show_options()
		"ExitButton":
			get_tree().quit()

# Función para iniciar el juego
func start_game():
	print("play")
	get_tree().change_scene_to_file("res://games/game1_scene.tscn")

# Función para abrir las opciones
func show_options():
	print("Abrir menú de opciones...")
	options.visible = true
	
func _on_close_options():
	options.visible = false
