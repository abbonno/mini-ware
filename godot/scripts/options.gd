extends Control

signal close_options
signal open_options
signal exit_to_main_menu

@onready var fullscreen = $OptionsPanel/OptionsBackground/OptionsButtonContainer/FullScreenButton
@onready var volume = $OptionsPanel/OptionsBackground/OptionsButtonContainer/VolumeSlider
@onready var returnButton = $OptionsPanel/OptionsBackground/OptionsButtonContainer/OptionsReturnButton
@onready var exitButton = $OptionsPanel/OptionsBackground/OptionsButtonContainer/OptionsExitButton
@onready var confirm_dialog = $ConfirmExitDialog

var config = ConfigFile.new()
var bus_index : int

func _ready():
	returnButton.connect("pressed", Callable(self, "_on_button_pressed").bind(returnButton.name))
	fullscreen.connect("pressed", Callable(self, "_on_button_pressed").bind(fullscreen.name))
	exitButton.connect("pressed", Callable(self, "_on_button_pressed").bind(exitButton.name))
	exitButton.visible = false
	
	if config.load(Globals.CONFIG_FILE) == OK:
		var volume_value = config.get_value("audio", "music_volume", 0.5)
		volume.value = volume_value
	volume.value_changed.connect(_on_volume_slider_value_changed)
	bus_index = AudioServer.get_bus_index("Music")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # Mapped to "ESC" button
		if self.visible:
			self.visible = false
			close_options.emit()
		else:
			self.visible = true
			open_options.emit()

func _on_button_pressed(button_name):
	match button_name:
		"OptionsReturnButton":
			self.visible = false
			close_options.emit()
		"FullScreenButton":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_WINDOWED)
			config.set_value("video", "fullscreen", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
			config.save(Globals.CONFIG_FILE)
		"OptionsExitButton":
			confirm_dialog.popup_centered()

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	config.set_value("audio", "music_volume", volume.value)
	config.save(Globals.CONFIG_FILE)

func _on_confirm_exit_dialog_confirmed():
	close_options.emit()
	exit_to_main_menu.emit()

func show_exit_button(enabled: bool):
	exitButton.visible = enabled
