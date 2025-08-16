extends Control

@onready var assetRecognition = AssetRecognition.new()
@onready var music_manager = get_tree().get_root().get_node("MusicManager")

@onready var background = $Background
@onready var titleLabel = $TitleLabel
@onready var logoPanel = $LogoPanel
@onready var button_container = $ButtonContainer
@onready var credits_button = $CreditsButton
@onready var options = $Options

func _ready():
	var config = ConfigFile.new()
	if config.load(Globals.CONFIG_FILE) == OK:
		var fullscreen = config.get_value("video", "fullscreen", false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		
		var volume = config.get_value("audio", "music_volume", 0.5)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume))
	
	titleLabel.text = ProjectSettings.get("application/config/name")
	assetRecognition.load_visual_resource(Globals.TITLE_PATH, Globals.TITLE_BACKGROUND, background)
	assetRecognition.load_visual_resource(Globals.TITLE_PATH, Globals.TITLE_LOGO, logoPanel)
	
	if !music_manager:
		music_manager = preload(Globals.MUSIC_MANAGER_SCENE).instantiate()
		get_tree().get_root().call_deferred("add_child", music_manager)
		await get_tree().process_frame
	var title_theme = load(Globals.TITLE_PATH + Globals.TITLE_THEME + "." + assetRecognition.get_extension(Globals.TITLE_PATH, Globals.TITLE_THEME))
	if title_theme:
		music_manager.play_music(title_theme)
	else:
		print("TITLE ERROR: Theme asset not found.")
	
	for button in button_container.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))
	credits_button.connect("pressed", Callable(self, "_on_button_pressed").bind(credits_button.name))

func _on_button_pressed(button_name):
	match button_name:
		"PlayButton":
			music_manager.stop_music()
			var transition = load(Globals.SCENE_TRANSITION_SCENE).instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene(preload(Globals.MAIN_MENU_SCENE).instantiate())
		"OptionsButton":
			options.visible = true
		"ExitButton":
			get_tree().quit()
		"CreditsButton":
			music_manager.stop_music()
			var transition = preload(Globals.SCENE_TRANSITION_SCENE).instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene(preload(Globals.CREDITS_SCENE).instantiate())
