extends CanvasLayer

@onready var fade = $ColorRect
@onready var anim = $AnimationPlayer

# Cambia de escena con fundido
func change_scene(scene_path: String):
	fade.visible = true
	anim.play("fade_in")
	await anim.animation_finished
	get_tree().change_scene_to_file(scene_path)
	anim.play("fade_out")
	await anim.animation_finished
	queue_free()
