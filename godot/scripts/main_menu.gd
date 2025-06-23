extends Control

@onready var assetRecognition = AssetRecognition.new()
@onready var config = ConfigFile.new()

@onready var background = $Background
@onready var level_picture = $LevelPicturePanel/LevelPicture
@onready var button_control = $ButtonControl
@onready var play_button = $ButtonControl/PlayButton
@onready var level_name = $LevelName
@onready var score = $LevelInfoPanel/LevelInfoContainer/ScoreLabelContainer/ScoresContainer/ScoreLabel
@onready var endless_score = $LevelInfoPanel/LevelInfoContainer/ScoreLabelContainer/ScoresContainer/EndlessScoreLabel
@onready var complete = $LevelInfoPanel/LevelInfoContainer/CompleteLabelContainer/CompleteLabel
@onready var description = $LevelInfoPanel/LevelInfoContainer/DescriptionLabelContainer/DescriptionLabel
@onready var options = $Options
@onready var endless_mode = $ButtonControl/EndlessModeButton

@onready var music_manager = get_tree().get_root().get_node("MusicManager")

var levels_list = []
var current_index

func _ready():
	
	# Cargar los niveles (array levels)
	assetRecognition.load_dir_names_from_directory(Globals.LEVELS_PATH, levels_list)
	
	# Cargar elementos visuales
	play_button.icon = load(Globals.IMG_PATH + Globals.PLAY_ICON) # completar carga icono
	assetRecognition.load_visual_resource(Globals.IMG_PATH, Globals.MAIN_MENU_BACKGROUND, background)
	
	# Cargar música
	if !music_manager:
		music_manager = preload(Globals.MUSIC_MANAGER_SCENE).instantiate()
		get_tree().get_root().call_deferred("add_child", music_manager)
		await get_tree().process_frame  # IMPORTANTE call deferred es una llamada asíncrona, por lo que si más tarde llamamos a play music no tendrá los nodos que necesita del árbol, es por eso que añadimos una espera (eS NECESARIA AQUÍ, PONERLA EN LA PROPIA FUNCIÓN DE REPRODUCCIÓN HARÁ QUE SE PRODUZCAN ESPERAS INFINITAS A LOS OTROS NODOS)
	music_manager.play_music(load(Globals.MUSIC_PATH + Globals.MAIN_MENU_THEME + ".ogg"))
	
	# Cargar botones
	for button in button_control.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))
	
	# Carga el último nivel jugado
	if config.load(Globals.CONFIG_FILE) == OK:
		current_index = config.get_value("level", "current_level", 0)
	
	# Carga los elementos que dependen de "current_index"
	update_level_display(current_index)

func update_level_display(index : int):
	var current = Globals.LEVELS_PATH + levels_list[index] + "/"
	# Level data
	assetRecognition.load_visual_resource(current, Globals.MAIN_MENU_LEVEL_PICTURE, level_picture)
	level_name.text = assetRecognition.get_json_element(current + Globals.MAIN_MENU_LEVEL_INFO + ".json", "level_name")
	description.text = assetRecognition.get_json_element(current + Globals.MAIN_MENU_LEVEL_INFO + ".json", "description")
	# Storage data
	print(Globals.DATA_FILE)
	print(levels_list[index] + "/score")
	print(assetRecognition.get_json_element(Globals.DATA_FILE, levels_list[index] + "/score", "---"))
	score.text = assetRecognition.get_json_element(Globals.DATA_FILE, levels_list[index] + "/score", "---")
	endless_score.text = str(assetRecognition.get_json_element(Globals.DATA_FILE, levels_list[index] + "/endless_score", 0))
	if assetRecognition.get_json_element(Globals.DATA_FILE, levels_list[index] + "/complete", false):
		complete.text = "COMPLETE"
		complete.set("theme_override_colors/font_color", Color.GREEN)
	else:
		complete.text = "---"
		complete.set("theme_override_colors/font_color", Color.RED)

func _on_button_pressed(button_name):
	match button_name:
		"OptionsButton":
			options.visible = true
		"PlayButton":
			music_manager.stop_music()
			var level_index = levels_list[current_index]
			print(level_index)
			var levelManagerScene = load(Globals.LEVEL_MANAGER_SCENE).instantiate()
			levelManagerScene.set_level_index(str(level_index))
			levelManagerScene.set_endless(endless_mode.button_pressed)
			var transition = load(Globals.SCENE_TRANSITION_SCENE).instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene(levelManagerScene)
		"ReturnButton":
			music_manager.stop_music()
			var transition = load(Globals.SCENE_TRANSITION_SCENE).instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene(load(Globals.TITLE_SCENE).instantiate())
		"NextLevelButton":
			current_index = (current_index + 1) % levels_list.size()
			config.set_value("level", "current_level", current_index)
			config.save(Globals.CONFIG_FILE)
			update_level_display(current_index)
		"PrevLevelButton":
			current_index = (current_index - 1) % levels_list.size()
			config.set_value("level", "current_level", current_index)
			config.save(Globals.CONFIG_FILE)
			update_level_display(current_index)
