extends Node

var current_minigame_index = 0
var lives = 3
var score = 0
var state = "intro"

@onready var hud_ui = $UIContainer
@onready var minigame_container = $GameContainer
@onready var video = $UIContainer/VideoStreamPlayer
#@onready var transition_layer = $TransitionLayer

var video_path = "res://Public/Vid/videoplayback.ogv"
var v = preload("res://Public/Vid/pato.ogv")
var m = preload("res://Levels/Level1/Minigame1/platformGame.tscn")
var minigame
var result

func _ready():
	# Cargar cinemática intro
	if FileAccess.file_exists(video_path):
		video.stream = load(video_path)
	video.play()
	await video.finished
	state = "control"
	main_iteration()

func main_iteration():
	match state:
		"control":
			video.stream = v
			video.play()
			await get_tree().create_timer(2).timeout
			video.stop()
			state = "level"
			main_iteration()
		"level":
			minigame = m.instantiate()
			minigame_container.add_child(minigame)
			print("tal")
			result = await minigame.win
			print(result)
			state = "control"
			for child in minigame_container.get_children():
				child.queue_free()
			main_iteration()
			
#func start_level():
	#lives = 3
	#score = 0
	#current_minigame_index = 0
	#update_ui()
	#show_intro_animation()

#func show_intro_animation():
	## Muestra la pantalla inicial de "¡Vamos!" y luego llama a next_minigame()
	#$AnimationPlayer.play("intro")
	#await $AnimationPlayer.animation_finished
	#next_minigame()

#func next_minigame():
	#if current_minigame_index >= minigames.size():
		#show_victory_screen()
		#return
#
	#var minigame_scene = minigames[current_minigame_index].instantiate()
	#minigame_container.clear_children()
	#minigame_container.add_child(minigame_scene)
	#
	## Conecta una señal del minijuego que indique si se gana o se pierde
	#minigame_scene.connect("finished", self, "_on_minigame_finished")

#func _on_minigame_finished(success):
	#if success:
		#score += 100  # o lo que corresponda
	#else:
		#lives -= 1
#
	#update_ui()
#
	#if lives <= 0:
		#show_game_over()
	#else:
		#current_minigame_index += 1
		#show_transition_to_next()

#func show_transition_to_next():
	#$AnimationPlayer.play("transition")  # Muestra mensaje, animación, etc.
	#await $AnimationPlayer.animation_finished
	#next_minigame()

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
