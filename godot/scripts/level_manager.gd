extends Node

signal minigame_result(win: bool)

@onready var UIContainer = $UIContainer
@onready var videoPlayer = $UIContainer/VideoStreamPlayer
@onready var popup_img = $UIContainer/PopupImg
@onready var popup_label = $UIContainer/PopupImg/PopupLabel
@onready var health_container = $UIContainer/HealthContainer
@onready var score_label = $UIContainer/ScoreLabel
@onready var minigame_container = $MinigameContainer
@onready var minigame_timer = $Timer
@onready var label = $Label

var current_minigame_index = 0
const MAX_LIVES = 4
var lives = MAX_LIVES
const MAX_SCORE = 10
var score = 0

var video_intro = preload("res://Public/Vid/intro.ogv")
var video_control = preload("res://Public/Vid/control.ogv")
var m = preload("res://Levels/Level1/Minigame1/platformGame.tscn")
var popup = preload("res://Public/Img/POPUP.png")
var health_icon = preload("res://icon.svg")
var minigame
var win

enum State { CONTROL, INSTRUCTION, GAME, WIN, LOSE, WIN_END, LOSE_END }

func _ready():
	minigame_timer.connect("timeout", Callable(self, "_on_time_up"))
	# Cargar popup
	popup_img.visible = false
	popup_img.texture = popup
	popup_label.text = "nose"
	# Cargar vidas+puntuacion
	health_container.visible = false
	for health in health_container.get_children():
		health.get_child(0).texture = health_icon
	score_label.visible = false
	score_label.text = str(score)
	# Cargar cinemática intro
	#videoPlayer.stream = video_intro
	#videoPlayer.play()
	#await videoPlayer.finished
	main_iteration(State.CONTROL)

func main_iteration(state : State):
	match state:
		State.CONTROL:
			# Ini video
			videoPlayer.stream = video_control
			videoPlayer.play()
			
			# Ini vidas + puntuación
			health_container.visible = true
			score_label.visible = true
			
			await get_tree().create_timer(2, false).timeout
			
			videoPlayer.stop()# Cambiar
			health_container.visible = false
			score_label.visible = false
			main_iteration(State.GAME) #Cambiar a INSTRUCTION tras desarrollar
		State.INSTRUCTION:
			# Ini popup
			popup_img.visible = true
			
			await get_tree().create_timer(2).timeout
			
			# Fin video
			videoPlayer.stop()
			
			# Fin vidas + puntuación
			health_container.visible = false
			score_label.visible = false
			
			# Fin popup
			popup_img.visible = false
			main_iteration(State.GAME)
		State.GAME:
			minigame = m.instantiate()
			minigame.win.connect(Callable(self, "_on_minigame_result"))
			minigame_container.add_child(minigame)
			minigame_timer.start() # Antes cambiar la duración por del timer por la especificada en el fichero de información del minijuego (teniendo en cuenta el speed up * 0.9)
			_run_timer_feedback()
			win = await self.minigame_result
			print(win)
			for child in minigame_container.get_children():
				child.queue_free()
			if win:
				score = score+1
				score_label.text = str(score)
				if score >= MAX_SCORE:
					main_iteration(State.WIN_END)
				else:
					main_iteration(State.WIN)
			else:
				lives = lives-1
				print(lives)
				health_container.get_child(lives).get_child(0).visible = false
				if lives <= 0:
					main_iteration(State.LOSE_END)
				else:
					main_iteration(State.LOSE)
		State.WIN:
			print("WIN")
			main_iteration(State.CONTROL)
		State.LOSE:
			print("LOSE")
			main_iteration(State.CONTROL)
		State.WIN_END:
			print("WIN_END")
			# Antes de volver al menú, pasar por una escena épica de victoria (video hasta que acabe)
			var transition = preload("res://scenes/sceneTransition.tscn").instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene("res://scenes/mainMenu.tscn")
		State.LOSE_END:
			print("LOSE_END")
			# Antes de volver al menú, pasar por una escena horrible de derrota (video hasta que acabe)
			var transition = preload("res://scenes/sceneTransition.tscn").instantiate()
			get_tree().root.add_child(transition)
			transition.change_scene("res://scenes/mainMenu.tscn")

func _run_timer_feedback():
	while minigame_timer.time_left > 0:
		print(minigame_timer.time_left)
		await get_tree().create_timer(0.1).timeout

func _on_time_up():
	emit_signal("minigame_result", false)
	
func _on_minigame_result(win: bool):
	minigame_timer.stop()
	emit_signal("minigame_result", win)
	
