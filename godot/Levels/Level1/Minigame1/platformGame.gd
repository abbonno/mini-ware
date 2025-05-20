extends Node2D

@onready var flag = $FlagArea
@onready var player = $Player

signal win

func _ready():
	flag.connect("body_entered", Callable(self, "_on_flag_reached"))

func _on_flag_reached(body):
	if body == player:
		emit_signal("win", true)
