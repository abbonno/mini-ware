extends Area2D

signal goal_reached

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("goal_reached")
		body.sprite.texture = load("res://Public/Levels/Level1/Minigames/Minigame1/win.png")
		
