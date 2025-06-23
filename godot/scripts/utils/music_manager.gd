extends Node

@onready var music = $Music
@onready var sfx = $SFX

var DURATION: float = 0.2

func play_music(stream, fade := true, duration := DURATION):
	if fade:
		fade_out_music(duration)
		await get_tree().create_timer(duration).timeout
	music.stream = stream
	music.volume_db = -40
	music.play()
	if fade:
		fade_in_music(duration)
	else:
		music.volume_db = 0

func stop_music(fade := true, duration := DURATION):
	if fade:
		await fade_out_music(duration)
	music.stop()

func fade_out_music(duration := DURATION):
	await _fade_volume(music, music.volume_db, -40, duration)

func fade_in_music(duration := DURATION):
	await _fade_volume(music, music.volume_db, 0, duration)

func _fade_volume(player, from: float, to: float, duration: float):
	var elapsed := 0.0
	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var t = elapsed / duration
		player.volume_db = lerp(from, to, t)
	player.volume_db = to

func play_sfx(stream):
	await ready
	sfx.stream = stream
	sfx.play()
	#var sfx_player = AudioStreamPlayer.new()
	#sfx_player.stream = stream
	#sfx_player.bus = "SFX"
	#sfx_player.autoplay = false
	#get_tree().root.add_child(sfx_player)
	#sfx_player.play()
	#sfx_player.connect("finished", sfx_player, "queue_free")
