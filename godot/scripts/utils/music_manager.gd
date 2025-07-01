extends Node

@onready var music = $Music
@onready var sfx = $SFX

var DURATION: float = 0.2

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
	if fade:
		_fade_out_music(fadeDuration)
		await get_tree().create_timer(fadeDuration).timeout
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

func play_sfx(stream):
	await ready # Puede ser innecesario
	sfx.stream = stream
	sfx.play()
	#var sfx_player = AudioStreamPlayer.new()
	#sfx_player.stream = stream
	#sfx_player.bus = "SFX"
	#sfx_player.autoplay = false
	#get_tree().root.add_child(sfx_player)
	#sfx_player.play()
	#sfx_player.connect("finished", sfx_player, "queue_free")
