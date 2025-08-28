extends CharacterBody2D

signal fell

const SPEED = 350.0
const JUMP_VELOCITY = -500.0

@onready var sprite = $PlayerSprite

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if position.y > 600:
		emit_signal("fell")
		sprite.texture = load("res://Public/Levels/Level1/Minigames/Minigame1/dead.png")
		
	move_and_slide()
