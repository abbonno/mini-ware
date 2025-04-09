extends Control

@onready var bg_texture = $Background
@onready var button_panel = $ButtonPanel


const BACKGROUND_PATH = "res://Public/Img/mainMenuBg.jpg"

func _ready():
	if FileAccess.file_exists(BACKGROUND_PATH):
		var texture = load(BACKGROUND_PATH)
		bg_texture.texture = texture
	
	for button in button_panel.get_children():
		print(button.name)
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))

func _on_button_pressed(button_name):
	match button_name:
		"PlayButton":
			get_tree().change_scene_to_file("res://games/platformGame.tscn")
		"ReturnButton":
			get_tree().change_scene_to_file("res://scenes/title.tscn")
		"NextLevelButton":
			print("todo")
			return
		"PrevLevelButton":
			print("todo")
			return
