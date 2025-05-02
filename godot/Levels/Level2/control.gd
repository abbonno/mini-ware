extends Control

var current_minigame_index = 0
var lives = 3
var score = 0
var minigames = []
var is_playing = false

@onready var minigame_container = $MinigameContainer
@onready var transition_layer = $TransitionLayer
@onready var hud_ui = $UI

func _ready():
	load_minigame_list()
	start_level()

func load_minigame_list():
	return false

func start_level():
	lives = 3
	score = 0
	current_minigame_index = 0
	update_ui()
	show_intro_animation()

func show_intro_animation():
	# Muestra la pantalla inicial de "¡Vamos!" y luego llama a next_minigame()
	$AnimationPlayer.play("intro")
	await $AnimationPlayer.animation_finished
	next_minigame()

func next_minigame():
	if current_minigame_index >= minigames.size():
		show_victory_screen()
		return

	var minigame_scene = minigames[current_minigame_index].instantiate()
	minigame_container.clear_children()
	minigame_container.add_child(minigame_scene)
	
	# Conecta una señal del minijuego que indique si se gana o se pierde
	minigame_scene.connect("finished", self, "_on_minigame_finished")
	is_playing = true

func _on_minigame_finished(success):
	is_playing = false
	if success:
		score += 100  # o lo que corresponda
	else:
		lives -= 1

	update_ui()

	if lives <= 0:
		show_game_over()
	else:
		current_minigame_index += 1
		show_transition_to_next()

func show_transition_to_next():
	$AnimationPlayer.play("transition")  # Muestra mensaje, animación, etc.
	await $AnimationPlayer.animation_finished
	next_minigame()

func show_game_over():
	# Mostrar pantalla de derrota
	print("Game Over")
	# Podrías ir a una escena de derrota o mostrar un menú

func show_victory_screen():
	# Mostrar pantalla de victoria
	print("¡Victoria!")

func update_ui():
	$UI/LivesLabel.text = "Vidas: %d" % lives
	$UI/ScoreLabel.text = "Puntos: %d" % score
