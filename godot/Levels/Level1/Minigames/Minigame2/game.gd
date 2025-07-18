extends Node2D

signal win

const COLORS = ["red", "blue", "green", "yellow"]
const INPUT_KEYS = [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]

@onready var redButton = $Grid/RedRect
@onready var blueButton = $Grid/BlueRect
@onready var greenButton = $Grid/GreenRect
@onready var yellowButton = $Grid/YellowRect

@onready var buttons := [
	$Grid/RedRect,
	$Grid/BlueRect,
	$Grid/GreenRect,
	$Grid/YellowRect
]

@onready var audio_player := $AudioStreamPlayer2D
@onready var label := $Label
@onready var grid := $Grid

var sequence = []
var player_input = []
var index = 0
var is_player_turn = false

func _ready():	
	_generate_sequence()
	label.text = "Observa..."
	await get_tree().create_timer(0.7, false).timeout
	_on_Timer_timeout()

func _on_Timer_timeout():
	if index < sequence.size():
		_show_color(sequence[index])
		index += 1
		await get_tree().create_timer(0.3, false).timeout
		_on_Timer_timeout()
	else:
		label.text = "¡Tu turno!"
		is_player_turn = true
		index = 0

func _show_color(color_index):
	var button = buttons[color_index]
	button.modulate = Color.GRAY # Simula "iluminación"
	audio_player.stream = load("res://Levels/Level1/Minigames/Minigame2/" + COLORS[color_index] + ".ogg")
	audio_player.play()
	await get_tree().create_timer(0.3).timeout
	button.modulate = Color(COLORS[color_index])

func _generate_sequence():
	sequence.clear()
	player_input.clear()
	index = 0
	for i in range(4):
		sequence.append(randi() % 4)
	print(sequence)

func _unhandled_input(event):
	if not is_player_turn:
		return

	if event is InputEventKey and event.pressed:
		var key_index = INPUT_KEYS.find(event.keycode)
		if key_index != -1:
			player_input.append(key_index)
			_show_color(key_index) # Reproduce feedback

			if player_input.size() > sequence.size():
				label.text = "Yeah!!"
				return

			if player_input[player_input.size() - 1] != sequence[player_input.size() - 1]:
				_on_player_fail()
				return

			if player_input.size() == sequence.size():
				_on_win()

func _on_win():
	label.text = "¡Bien hecho!"
	emit_signal("win", true)

func _on_player_fail():
	label.text = "¡Fallaste!"
	emit_signal("win", false)  # Si quieres emitir "false" como parámetro
