extends Control

@onready var bg_texture = $Background
@onready var game_picture = $GamePicture
@onready var game_label = $GameLabel
@onready var button_control = $ButtonControl
@onready var options = $Options
@onready var label1 = $DescriptionPanel/VBoxContainer/MarginContainer/Label
@onready var label2 = $DescriptionPanel/VBoxContainer/MarginContainer2/Label2
@onready var label3 = $DescriptionPanel/VBoxContainer/MarginContainer3/RichTextLabel

const BACKGROUND_PATH = "res://Public/Img/mainMenuBg.jpg"
const LEVELS_PATH = "res://Levels"

var levels = []
var current_index = 0

func _ready():
	load_levels_from_directory(LEVELS_PATH)
	update_level_display()
	
	options.visible = false
	options.close_options.connect(_on_close_options)
	
	if FileAccess.file_exists(BACKGROUND_PATH):
		var texture = load(BACKGROUND_PATH)
		bg_texture.texture = texture
	
	for button in button_control.get_children():
		print(button.name)
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))

func load_levels_from_directory(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir() and not folder_name.begins_with("."):
				var level_path = path + "/" + folder_name
				var scene_path = level_path + "/control.tscn"
				var image_path = level_path + "/picture.png" #modificar para que acepte algo más que png
				var info_path = level_path + "/info.json"
				var info = load_level_info(info_path)
				if FileAccess.file_exists(scene_path):
					levels.append({
						"name": folder_name,
						"scene": scene_path,
						"game_picture": image_path,
						"puntuacion": info.puntuacion,
						"superado": info.superado,
						"descripcion": info.descripcion
					})
			folder_name = dir.get_next()
		dir.list_dir_end()

func update_level_display():
	var current = levels[current_index]
	if FileAccess.file_exists(current["game_picture"]):
		var texture = load(current["game_picture"])
		game_picture.texture = texture
	game_label.text = current["name"]
	label1.text = current["puntuacion"]
	label2.text = current["superado"]
	label3.text = current["descripcion"]

func load_level_info(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var level_data = JSON.parse_string(content)
		if level_data == null:
			push_error("Error al parsear el JSON")
		return level_data

func _on_button_pressed(button_name):
	match button_name:
		"OptionsButton":
			show_options()
		"PlayButton":
			get_tree().change_scene_to_file(levels[current_index]["scene"])
		"ReturnButton":
			get_tree().change_scene_to_file("res://scenes/title.tscn")
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
