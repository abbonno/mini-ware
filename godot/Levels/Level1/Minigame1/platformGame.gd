extends Node2D

@onready var label = $Label

signal win

func _ready():
	$Timer.start()
	$Flag.connect("body_entered", Callable(self, "_on_flag_reached"))
	$Timer.connect("timeout", Callable(self, "_on_time_up"))

func _process(delta):
	label.text = str($Timer.time_left).pad_decimals(1)

func _on_flag_reached(body):
	if body.name == "Player":
		$Timer.stop()
		emit_signal("win", true)
		queue_free()  # opcional: cierra el minijuego

func _on_time_up():
	show_result("¡Has perdido!")
	emit_signal("win", false)
	queue_free()  # opcional: cierra el minijuego

func show_result(text):
	$Label.text = text
	$Label.show()
