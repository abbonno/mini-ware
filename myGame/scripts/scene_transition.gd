extends CanvasLayer

@onready var fadeTexture = $ColorRect
@onready var fadeAnimation = $AnimationPlayer

func change_scene(scene):
	fadeTexture.visible = true
	fadeAnimation.play("fade_in")
	await fadeAnimation.animation_finished
	
	var current_scene = get_tree().current_scene
	if current_scene and current_scene != self:
		current_scene.queue_free()

	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	
	fadeAnimation.play("fade_out")
	await fadeAnimation.animation_finished
	queue_free()
