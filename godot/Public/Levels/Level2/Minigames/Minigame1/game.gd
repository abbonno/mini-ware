extends Node2D

signal win

@onready var player_scene = preload("res://Levels/Level1/Minigames/Minigame1/Player.tscn")
@onready var platform_scene = preload("res://Levels/Level1/Minigames/Minigame1/Platform.tscn")
@onready var flag_scene = preload("res://Levels/Level1/Minigames/Minigame1/Flag.tscn")

func _ready():
	var pattern = choose_level_pattern()
	spawn_level(pattern)

func choose_level_pattern() -> Array:
	# Ejemplo de patrón sencillo
	return [
		{"type": "platform", "pos": Vector2(300, 500)},
		{"type": "flag", "pos": Vector2(400, 450)},
		{"type": "player", "pos": Vector2(250, 450)},
	]
	#return [
		#{"type": "platform", "pos": Vector2(100, 200)},
		#{"type": "platform", "pos": Vector2(400, 350)},
		#{"type": "platform", "pos": Vector2(600, 600)},
		#{"type": "flag", "pos": Vector2(700, 500)},
		#{"type": "player", "pos": Vector2(100, 150)},
	#]

func spawn_level(pattern: Array):
	for element in pattern:
		var node
		match element.type:
			"platform":
				node = platform_scene.instantiate()
			"player":
				node = player_scene.instantiate()
				node.connect("fell", Callable(self, "_on_player_fell"))
				node.add_to_group("player")
			"flag":
				node = flag_scene.instantiate()
				node.connect("goal_reached", Callable(self, "_on_win"))
			_:
				continue
		node.position = element.pos
		add_child(node)

func _on_win():
	print("¡Victoria!")
	emit_signal("win", true)

func _on_player_fell():
	print("Jugador cayó")
	emit_signal("win", false)
