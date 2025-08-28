extends Node2D

signal win

@onready var music_manager = get_tree().get_root().get_node("MusicManager")

@onready var player_scene = load(get_script().resource_path.get_base_dir().path_join("Player.tscn"))
@onready var platform_scene = load(get_script().resource_path.get_base_dir().path_join("Platform.tscn"))
@onready var flag_scene = load(get_script().resource_path.get_base_dir().path_join("Flag.tscn"))

var score = 0

func _ready():
	var pattern = choose_level_pattern()
	spawn_level(pattern)

func set_game_info(levelScore):
	score = levelScore

func choose_level_pattern() -> Array:
	if(score >= 0):
		return [
			{"type": "platform", "pos": Vector2(200, 500)},
			{"type": "platform", "pos": Vector2(800, 450)},
			{"type": "flag", "pos": Vector2(900, 390)},
			{"type": "player", "pos": Vector2(150, 470)},
		]
	else: 
		return [
			{"type": "platform", "pos": Vector2(100, 200)},
			{"type": "platform", "pos": Vector2(300, 350)},
			{"type": "platform", "pos": Vector2(1000, 500)},
			{"type": "flag", "pos": Vector2(1100, 440)},
			{"type": "player", "pos": Vector2(100, 150)},
		]

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
	music_manager.play_sound(load("res://Public/Levels/Level1/Minigames/Minigame1/win.ogg"))
	_set_paused_recursively($".", true)
	emit_signal("win", true)

func _on_player_fell():
	music_manager.play_sound(load("res://Public/Levels/Level1/Minigames/Minigame1/hit.ogg"))
	_set_paused_recursively($".", true)
	emit_signal("win", false)

func _set_paused_recursively(node: Node, paused: bool) -> void:
	node.set_process(not paused)
	node.set_physics_process(not paused)
	node.set_process_input(not paused)
	node.set_process_unhandled_input(not paused)
	node.set_process_unhandled_key_input(not paused)
	for child in node.get_children():
		if child is Node:
			_set_paused_recursively(child, paused)
