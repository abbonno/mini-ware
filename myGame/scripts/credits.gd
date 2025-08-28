extends Control

@onready var assetRecognition = AssetRecognition.new()

@onready var music_manager = get_tree().get_root().get_node("MusicManager")

@onready var background = $Background
@onready var scroll = $PanelContainer/ScrollContainer
@onready var label = $PanelContainer/ScrollContainer/VBoxContainer/RichTextLabel
@onready var title_button = $TitleButton

var scroll_speed = 80.0
var scroll_acceleration = 200.0
var is_paused = false

func _ready():
	if !music_manager:
		music_manager = preload(Globals.MUSIC_MANAGER_SCENE).instantiate()
		get_tree().get_root().call_deferred("add_child", music_manager)
		await get_tree().process_frame
	var title_theme = load(Globals.CREDITS_PATH + Globals.CREDITS_THEME + "." + assetRecognition.get_extension(Globals.CREDITS_PATH, Globals.CREDITS_THEME))
	if title_theme:
		music_manager.play_music(title_theme)
	else:
		print("CREDITS ERROR: Theme asset not found.")
	
	title_button.connect("pressed", Callable(self, "_on_button_pressed").bind(title_button.name))

	assetRecognition.load_visual_resource(Globals.CREDITS_PATH, Globals.CREDITS_BACKGROUND, background)
	
	load_credits(Globals.CREDITS_PATH + Globals.CREDITS)

func load_credits(path: String):
	if not FileAccess.file_exists(path):
		label.text = "[color=red]Archivo de créditos no encontrado.[/color]"
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	var lines = file.get_as_text().split("\n")
	file.close()

	label.clear()
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("[") and line.ends_with("]"):
			var title = line.substr(1, line.length() - 2)
			label.append_text("[center][b]" + title + "[/b][/center]\n")
		elif line != "":
			label.append_text("[center]" + line + "[/center]\n")
		else:
			label.append_text("\n")  # Espaciado

	label.scroll_active = false
	label.bbcode_enabled = true

func _process(delta):
	if is_paused:
		return
	
	var speed = scroll_speed
	if Input.is_action_pressed("ui_down"):
		speed = scroll_acceleration
	
	scroll.scroll_vertical += speed * delta

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		is_paused = true
	elif event.is_action_released("ui_accept") or event.is_action_released("ui_select"):
		is_paused = false

func _on_button_pressed(button_name):
	match button_name:
		"TitleButton":
			music_manager.stop_music()
			var transition = load(Globals.SCENE_TRANSITION_SCENE).instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene(load(Globals.TITLE_SCENE).instantiate())
