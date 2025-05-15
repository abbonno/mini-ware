extends Node2D

var time := 0.0
const DURATION := 2.0
const FREQUENCY := 2.0
const AMPLITUDE := 50.0
const SPEED := 2.0

func _process(delta):
	time += delta
	queue_redraw()

func _draw():
	var width := get_viewport_rect().size.x
	var center_y := get_viewport_rect().size.y / 2
	var points := []

	for x in range(0, int(width), 5):
		var y := sin((x * 0.02 * FREQUENCY) + (time * SPEED)) * AMPLITUDE
		points.append(Vector2(x, center_y + y))

	draw_polyline(points, Color.WHITE, 2.0)
