extends CanvasLayer

@onready var fadeTexture = $ColorRect
@onready var fadeAnimation = $AnimationPlayer

# Cambia de escena con fundido
func change_scene(scene):
	fadeTexture.visible = true
	fadeAnimation.play("fade_in")
	await fadeAnimation.animation_finished
	
	# Eliminar escena actual si existe
	var current_scene = get_tree().current_scene
	if current_scene and current_scene != self:
		current_scene.queue_free()

	# Agregar la nueva escena y registrarla como actual
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	
	#get_tree().change_scene_to_packed(scene)
	fadeAnimation.play("fade_out")
	await fadeAnimation.animation_finished
	queue_free()
