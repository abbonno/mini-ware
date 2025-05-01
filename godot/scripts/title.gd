extends Control

@onready var music_player = $MusicPlayer
@onready var background = $Background
@onready var button_container = $ButtonContainer
@onready var options = $Options
@onready var titleLabel = $TitleLabel
@onready var logoPanel = $LogoPanel

const IMG_PATH = "res://Public/Img/"
const BACKGROUND = "background"
const LOGO = "logo"
const MUSIC_PATH = "res://Public/Music/titleTheme.ogg"
const CONFIG_FILE = "res://config/settings.cfg"

var project_name = ProjectSettings.get("application/config/name") # Modificar si se quiere cambiar el nombre del juego

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
	titleLabel.text = project_name
	
	# Carga recursos visuales
	var dir = DirAccess.open(IMG_PATH)
	if dir == null:
		print("ERROR: Carpeta Assets no encontrada:" + IMG_PATH)
		return
	var files = dir.get_files()
	var regex = RegEx.new()
	
		# Fondo pantalla
	regex.compile("^" + BACKGROUND + "\\.(.+)$")
	for file in files:
		var match = regex.search(file)
		if match:
			var ext = match.get_string(1).to_lower()
			var path = IMG_PATH + file
			match_type(ext, path, background)
			break
	
		# Logo título
	regex.compile("^" + LOGO + "\\.(.+)$")
	for file in files:
		var match = regex.search(file)
		if match:
			var ext = match.get_string(1).to_lower()
			var path = IMG_PATH + file
			match_type(ext, path, logoPanel)
			break
	
	# Carga música título
	if FileAccess.file_exists(MUSIC_PATH):
		var music = load(MUSIC_PATH)
		music_player.stream = music
		music_player.stream.loop = true
	music_player.play()
	
	# Carga botones
	for button in button_container.get_children():
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.name))

func match_type(ext: String, path: String, container):
	match ext:
		"png", "jpg", "jpeg", "webp": # Carga de una imagen
			var sprite_file = load(path)
			if sprite_file != null:
				var sprite = TextureRect.new()
				sprite.texture = sprite_file
				sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
				sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH
				container.add_child(sprite)
			else:
				print("ERROR: La imagen no ha sido cargada correctamente: ", path)
				
		"webm", "ogv": # Carga de un vídeo
			var video_file = load(path)
			if video_file != null:
				var video = VideoStreamPlayer.new()
				video.stream = video_file
				video.set_anchors_preset(Control.PRESET_FULL_RECT)
				video.autoplay = true
				video.expand = true
				video.loop = true
				container.add_child(video)
			else:
				print("ERROR: El vídeo no ha sido cargado correctamente: ", path)
				
		"gdshader": #Carga de un shader
			var shader_file = load(path)
			if shader_file != null:
				var shader_material = ShaderMaterial.new()
				shader_material.shader = shader_file
				var shader = ColorRect.new()
				shader.material = shader_material
				shader.set_anchors_preset(Control.PRESET_FULL_RECT)
				shader.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				shader.size_flags_vertical = Control.SIZE_EXPAND_FILL
				container.add_child(shader)
			else:
				print("ERROR: El shader no ha cargado correctamente: ", path)
				
		_:
			print("ERROR: Extensión no soportada:", ext) #inicio control errores, acordarse de poner más

func _on_button_pressed(button_name):
	match button_name:
		"PlayButton":
			get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
		"OptionsButton":
			options.visible = true
		"ExitButton":
			get_tree().quit()

func _on_close_options():
	options.visible = false
