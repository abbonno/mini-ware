extends Control

@onready var assetRecognition = AssetRecognition.new()

@onready var titleLabel = $TitleLabel
@onready var background = $Background
@onready var logoPanel = $LogoPanel
@onready var music_player = $MusicPlayer
@onready var button_container = $ButtonContainer
@onready var options = $Options

@onready var music_manager = get_tree().get_root().get_node("MusicManager")

const CONFIG_FILE = "res://config/settings.cfg"
const IMG_PATH = "res://Public/Img/"
const BACKGROUND = "background"
const LOGO = "logo"
const MUSIC_PATH = "res://Public/Music/titleTheme.ogg"

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
	if !music_manager:
		music_manager = preload("res://scenes/musicManager.tscn").instantiate()
		get_tree().get_root().call_deferred("add_child", music_manager)
		await get_tree().process_frame  # IMPORTANTE call deferred es una llamada asíncrona, por lo que si más tarde llamamos a play music no tendrá los nodos que necesita del árbol, es por eso que añadimos una espera (eS NECESARIA AQUÍ, PONERLA EN LA PROPIA FUNCIÓN DE REPRODUCCIÓN HARÁ QUE SE PRODUZCAN ESPERAS INFINITAS A LOS OTROS NODOS)
	music_manager.play_music(load(MUSIC_PATH))
	
	# Carga botones
	for button in button_container.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))

func _on_button_pressed(button_name):
	match button_name:
		"PlayButton":
			music_manager.stop_music()
			var transition = preload("res://scenes/sceneTransition.tscn").instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene("res://scenes/mainMenu.tscn")
		"OptionsButton":
			options.visible = true
		"ExitButton":
			get_tree().quit()

func _on_close_options():
	options.visible = false
