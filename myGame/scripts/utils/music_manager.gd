extends Node

@onready var music = $Music
@onready var SFX = $SFX

var DURATION: float = 0.2

func _ready():
	music.connect("finished", Callable(self, "_on_music_finished"))

func _fade_out_music(fadeDuration := DURATION):
	await _fade_volume(music, music.volume_db, -40, fadeDuration)

func _fade_in_music(fadeDuration := DURATION):
	await _fade_volume(music, music.volume_db, 0, fadeDuration)

func _fade_volume(player, from: float, to: float, fadeDuration: float):
	var elapsed := 0.0
	while elapsed < fadeDuration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var t = elapsed / fadeDuration
		player.volume_db = lerp(from, to, t)
	player.volume_db = to

func play_music(stream, fade := true, fadeDuration := DURATION):
	music.stream = stream
	music.volume_db = -40
	music.play()
	if fade:
		_fade_in_music(fadeDuration)
	else:
		music.volume_db = 0

func stop_music(fade := true, fadeDuration := DURATION):
	if fade:
		await _fade_out_music(fadeDuration)
	music.stop()
	
func play_sound(stream):
	SFX.stream = stream
	SFX.play()

func _on_music_finished():
	if music.stream:
		music.play()
