extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Fade in")
	yield(get_tree().create_timer(6), "timeout")
	$AnimationPlayer.play("Fade out")
	yield(get_tree().create_timer(3), "timeout")
	get_tree().change_scene("res://MainMenu.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
