extends Control

@onready var assetRecognition = AssetRecognition.new()

@onready var background = $Background
@onready var level_picture = $LevelPicturePanel/LevelPicture
@onready var button_control = $ButtonControl
@onready var play_button = $ButtonControl/PlayButton
@onready var level_name = $LevelName
@onready var score = $LevelInfoPanel/LevelInfoContainer/ScoreLabelContainer/ScoreLabel
@onready var complete = $LevelInfoPanel/LevelInfoContainer/CompleteLabelContainer/CompleteLabel
@onready var description = $LevelInfoPanel/LevelInfoContainer/DescriptionLabelContainer/DescriptionLabel
@onready var options = $Options

@onready var music_manager = get_tree().get_root().get_node("MusicManager")

var levels_list = []
var current_index = 0 # en el guardado de la información del juego almacenar el último nivel en el que se estuvo para comenzar desde ahí la próxima vez que se abra

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
	
	# Carga los elementos que dependen de "current_index"
	update_level_display()

func update_level_display():
	var current = Globals.LEVELS_PATH + "/" + levels_list[current_index] + "/"
	assetRecognition.load_visual_resource(current, Globals.MAIN_MENU_LEVEL_PICTURE, level_picture)
	assetRecognition.load_json_resource(current, Globals.MAIN_MENU_LEVEL_INFO, level_name, "level_name")
	assetRecognition.load_json_resource(current, Globals.MAIN_MENU_LEVEL_INFO, score, "score")
	assetRecognition.load_json_resource(current, Globals.MAIN_MENU_LEVEL_INFO, complete, "complete")
	assetRecognition.load_json_resource(current, Globals.MAIN_MENU_LEVEL_INFO, description, "description")

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
			print(levelManagerScene.level_index)
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
			update_level_display()
		"PrevLevelButton":
			current_index = (current_index - 1) % levels_list.size()
			update_level_display()
