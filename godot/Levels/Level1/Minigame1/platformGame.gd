extends Node2D

@onready var label = $Label

func _ready():
	$Timer.start()
	$Flag.connect("body_entered", Callable(self, "_on_flag_reached"))
	$Timer.connect("timeout", Callable(self, "_on_time_up"))

func _process(delta):
	label.text = str($Timer.time_left).pad_decimals(1)

func _on_flag_reached(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Levels/Level1/control.tscn")

func _on_time_up():
	show_result("¡Has perdido!")

func show_result(text):
	$Label.text = text
	$Label.show()
	get_tree().paused = true
