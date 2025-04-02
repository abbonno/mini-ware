extends Control

signal close_options #para cerrar la pantalla de opciones desde cualquier escena

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
	if config.load("res://config/settings.cfg") == OK:
		var volume_value = config.get_value("audio", "music_volume", 0.5)
		volume.value = volume_value  # Actualiza el slider
	volume.value_changed.connect(_on_volume_slider_value_changed)
	bus_index = AudioServer.get_bus_index("Music")

func _on_button_pressed(button_name):
	match button_name:
		"OptionsReturnButton":
			close_options.emit() #Recordar mandarlo al nodo que lo llama (ya sea el título o alguna otra parte del juego)
		"FullScreenButton":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_WINDOWED)
			config.set_value("video", "fullscreen", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
			config.save("res://config/settings.cfg")

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	config.set_value("audio", "music_volume", volume.value)
	config.save("res://config/settings.cfg")
