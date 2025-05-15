extends Node2D

@onready var pulsing_image = $Overlay/PulsingImage
@onready var overlay_label = $Overlay/OverlayLabel

var time := 0.0
var show_overlay := false
const DURATION := 2.0  # Tiempo antes de mostrar overlay

func _ready():
	pulsing_image.visible = false
	overlay_label.visible = false

func _process(delta):
	time += delta

	if time >= DURATION and not show_overlay:
		show_overlay = true
		pulsing_image.visible = true
		overlay_label.visible = true
		
	if time >= DURATION*2:
		get_tree().change_scene_to_file("res://Levels/Level1/control2.tscn")  # Cambia por tu escena

	if show_overlay:
		# Efecto de agrandar y achicar con seno
		var scale_amount = 1.0 + 0.1 * sin(time * 4.0)
		pulsing_image.scale = Vector2(scale_amount, scale_amount)
