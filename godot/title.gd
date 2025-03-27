extends Control

@onready var music_player = $MusicPlayer
@onready var bg_texture = $Background
@onready var button_container = $ButtonContainer
@onready var options = $Options

const BACKGROUND_PATH = "res://Public/Img/background.jpg"
const MUSIC_PATH = "res://Public/Music/titleTheme.ogg"
const BUTTON_TEXTURE = "res://Public/Img/buttonTextureNormal.png"

func _ready():
	options.visible = false
	if FileAccess.file_exists(BACKGROUND_PATH):
		var texture = load(BACKGROUND_PATH)
		print(texture.get_size().x)
		bg_texture.texture = texture
	if FileAccess.file_exists(MUSIC_PATH):
		var music = load(MUSIC_PATH)
		music_player.stream = music

	music_player.play()
	
	for button in button_container.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))
	$Options/Panel/ColorRect/VBoxContainer/Return.connect("pressed", Callable(self, "_on_button_pressed").bind($Options/Panel/ColorRect/VBoxContainer/Return.name))
	$Options/Panel/ColorRect/VBoxContainer/FullScreen.connect("pressed", Callable(self, "_on_button_pressed").bind($Options/Panel/ColorRect/VBoxContainer/FullScreen.name))

# Manejar la lógica de los botones
func _on_button_pressed(button_name):
	print(button_name)
	match button_name:
		"PlayButton":
			start_game()
		"OptionsButton":
			show_options()
		"ExitButton":
			get_tree().quit()
		"Return":
			options.visible = false
		"FullScreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_WINDOWED)


# Función para iniciar el juego
func start_game():
	print("play")
	get_tree().change_scene_to_file("res://games/game1_scene.tscn")

# Función para abrir las opciones
func show_options():
	print("Abrir menú de opciones...")
	options.visible = true
