extends CanvasLayer

@onready var fadeTexture = $ColorRect
@onready var fadeAnimation = $AnimationPlayer

# Cambia de escena con fundido
func change_scene(scene_path: String):
	fadeTexture.visible = true
	fadeAnimation.play("fade_in")
	await fadeAnimation.animation_finished
	get_tree().change_scene_to_file(scene_path)
	fadeAnimation.play("fade_out")
	await fadeAnimation.animation_finished
	queue_free()
