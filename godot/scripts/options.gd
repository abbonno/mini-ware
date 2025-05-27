extends Control

signal close_options #para cerrar la pantalla de opciones desde cualquier escena
signal open_options #para abrir la pantalla de opciones in-game (activar pausa)

@onready var fullscreen = $OptionsPanel/OptionsBackground/OptionsButtonContainer/FullScreenButton
@onready var volume = $OptionsPanel/OptionsBackground/OptionsButtonContainer/VolumeSlider
@onready var returnButton = $OptionsPanel/OptionsBackground/OptionsButtonContainer/OptionsReturnButton

var config = ConfigFile.new()
var bus_index : int

func _ready():
	# Cargar elementos visuales
	returnButton.connect("pressed", Callable(self, "_on_button_pressed").bind(returnButton.name))
	fullscreen.connect("pressed", Callable(self, "_on_button_pressed").bind(fullscreen.name))
	
	# Cargar elementos de audio
	if config.load(Globals.CONFIG_FILE) == OK:
		var volume_value = config.get_value("audio", "music_volume", 0.5)
		volume.value = volume_value  # Actualiza el slider
	volume.value_changed.connect(_on_volume_slider_value_changed)
	bus_index = AudioServer.get_bus_index("Music")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # "ui_cancel" está mapeado por defecto a Esc
		if self.visible:
			self.visible = false
			close_options.emit() #Recordar mandarlo al nodo que lo llama (ya sea el título o alguna otra parte del juego)
		else:
			self.visible = true
			open_options.emit()

func _on_button_pressed(button_name):
	match button_name:
		"OptionsReturnButton":
			self.visible = false
			close_options.emit() #Recordar mandarlo al nodo que lo llama (ya sea el título o alguna otra parte del juego)
		"FullScreenButton":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_WINDOWED)
			config.set_value("video", "fullscreen", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
			config.save(Globals.CONFIG_FILE)

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	config.set_value("audio", "music_volume", volume.value)
	config.save(Globals.CONFIG_FILE)
