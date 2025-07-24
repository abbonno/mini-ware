extends Control

@onready var assetRecognition = AssetRecognition.new()
@onready var config = ConfigFile.new()
@onready var music_manager = get_tree().get_root().get_node("MusicManager")

@onready var background = $Background
@onready var level_picture = $LevelPicturePanel
@onready var button_control = $ButtonControl
@onready var play_button = $ButtonControl/PlayButton
@onready var endless_mode_button = $ButtonControl/EndlessModeButton
@onready var level_name = $LevelName
@onready var complete = $LevelInfoPanel/LevelInfoContainer/CompleteLabelContainer/CompleteLabel
@onready var score = $LevelInfoPanel/LevelInfoContainer/ScoreLabelContainer/ScoresContainer/ScoreLabel
@onready var endless_score = $LevelInfoPanel/LevelInfoContainer/ScoreLabelContainer/ScoresContainer/EndlessScoreLabel
@onready var description = $LevelInfoPanel/LevelInfoContainer/DescriptionLabelContainer/DescriptionLabel
@onready var options = $Options

var levels_list = []
var current_index

func _ready():
	assetRecognition.load_dir_names_from_directory(Globals.LEVELS_PATH, levels_list)
	
	play_button.icon = load(Globals.MAIN_MENU_PATH + Globals.PLAY_ICON + "." + assetRecognition.get_extension(Globals.MAIN_MENU_PATH, Globals.PLAY_ICON))
	assetRecognition.load_visual_resource(Globals.MAIN_MENU_PATH, Globals.MAIN_MENU_BACKGROUND, background)
	
	if !music_manager:
		music_manager = preload(Globals.MUSIC_MANAGER_SCENE).instantiate()
		get_tree().get_root().call_deferred("add_child", music_manager)
		await get_tree().process_frame
	music_manager.play_music(load(Globals.MAIN_MENU_PATH + Globals.MAIN_MENU_THEME + "." + assetRecognition.get_extension(Globals.MAIN_MENU_PATH, Globals.MAIN_MENU_THEME)))
	
	for button in button_control.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))
	
	current_index = config.get_value("level", "current_level", 0)
	update_level_display(current_index)
	
	if !level_has_minigame(current_index):
		play_button.disabled = true

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
			levelManagerScene.set_endless(endless_mode_button.button_pressed)
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

func update_level_display(level_index : int):
	var current_level_path = Globals.LEVELS_PATH + levels_list[level_index] + "/"

	assetRecognition.load_visual_resource(current_level_path, Globals.MAIN_MENU_LEVEL_PICTURE, level_picture)
	level_name.text = assetRecognition.get_json_element(current_level_path + Globals.MAIN_MENU_LEVEL_INFO, Globals.LEVEL_NAME_FIELD)
	description.text = assetRecognition.get_json_element(current_level_path + Globals.MAIN_MENU_LEVEL_INFO, Globals.DESCRIPTION_FIELD)

	score.text = str(assetRecognition.get_encrypted_json_element(Globals.DATA_FILE, levels_list[level_index] + "/" + Globals.SCORE_FIELD, "---"))
	endless_score.text = str(assetRecognition.get_encrypted_json_element(Globals.DATA_FILE, levels_list[level_index] + "/" + Globals.ENDLESS_SCORE_FIELD, 0))
	if assetRecognition.get_encrypted_json_element(Globals.DATA_FILE, levels_list[level_index] + "/" + Globals.COMPLETE_FIELD, false):
		complete.text = "COMPLETE"
		complete.set("theme_override_colors/font_color", Color.GREEN)
		var score_map = {"1": "C", "2": "B", "3": "A", "4": "S"}
		score.text = score_map.get(str(assetRecognition.get_encrypted_json_element(Globals.DATA_FILE, levels_list[level_index] + "/" + Globals.SCORE_FIELD, "---")), "ERROR")
	else:
		complete.text = "---"
		complete.set("theme_override_colors/font_color", Color.RED)
	
	if level_has_minigame(current_index):
		play_button.disabled = false

func level_has_minigame(level_index: int):
	var minigames_base_path = Globals.LEVELS_PATH + levels_list[level_index] + "/" + Globals.MINIGAMES_DIR
	var dir = DirAccess.open(minigames_base_path)
	if dir == null:
		print("ERROR: Minigames folder not found on the path: ", minigames_base_path)
		return false
	
	dir.list_dir_begin()
	var first_folder = dir.get_next()
	dir.list_dir_end()
	var minigame_path = minigames_base_path + first_folder + "/"
	var subdir = DirAccess.open(minigame_path)
	subdir.list_dir_begin()
	var file = subdir.get_next()
	while file != "":
		if file == "Game.tscn":
			return true
		file = subdir.get_next()
	subdir.list_dir_end()
	print("ERROR: Minigame scene not found on: ", minigame_path)
	return false
