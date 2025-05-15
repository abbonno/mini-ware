extends Control

@onready var video_stream_player = $VideoStreamPlayer

var video = "res://Levels/Level1/peter.ogv"
var vidas = 4
var puntuacion = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if FileAccess.file_exists(video):
		var stream = load(video)
		video_stream_player.stream = stream
	video_stream_player.play()
	video_stream_player.connect("finished", Callable(self, "_on_video_finished"))
	$Vidas.text = "Vidas: " + str(vidas)
	$Puntuacion.text = "Nivel: " + str(puntuacion)

func _on_video_finished():
	get_tree().change_scene_to_file("res://Levels/Level1/Minigame1/platformGame.tscn")
