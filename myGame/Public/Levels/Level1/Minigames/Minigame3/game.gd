extends Node2D

signal win

@onready var music_manager = get_tree().get_root().get_node("MusicManager")

@onready var label_text = $Background/PageRect/TextLabel
@onready var label = $Background/VSplitContainer/Label
@onready var score_label = $Background/VSplitContainer/ScoreLabel

var score = 0
var goalNumber = 200
var nChar = 0

func _ready():
	if score >= 2:
		goalNumber = 300
	score_label.text = str(nChar) + "/" + str(goalNumber)
	pass

func set_game_info(levelScore):
	score = levelScore

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		music_manager.play_sound(load("res://Public/Levels/Level1/Minigames/Minigame3/keyPress.ogg"))
		var ch = OS.get_keycode_string(event.physical_keycode)
		nChar = nChar + 1
		score_label.text = str(nChar) + "/" + str(goalNumber)
		if ch.length() == 1:
			label_text.text += ch
		elif ch == "Enter":
			label_text.text += "\n"
		elif ch == "Space":
			label_text.text += " "
		if nChar == goalNumber/2.0:
			label.text = "¡Ya queda poco!"
		if nChar == goalNumber:
			_on_win()

func _on_win():
	music_manager.play_sound(load("res://Public/Levels/Level1/Minigames/Minigame3/win.ogg"))
	label.text = "¡Bien hecho!"
	emit_signal("win", true)
