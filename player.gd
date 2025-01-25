extends CharacterBody2D

const GRAVITY = 200.0
const WALK_SPEED = 2000
const BORINGNESS = 0.8
var sticking_to_surface = false

func _physics_process(delta):
	if not sticking_to_surface:
		velocity += Input.get_vector("move_left", "move_right", "move_up", "move_down") * WALK_SPEED * delta

	var kinematic_collision = move_and_collide(velocity * delta)
	if kinematic_collision:
		if sticking_to_surface:
			velocity = Vector2.ZERO
		else:
			velocity = velocity.bounce(kinematic_collision.get_normal()) * BORINGNESS
	else:
		if not sticking_to_surface:
			velocity.y += delta * GRAVITY

func _input(event):
	if event.is_action_pressed("reset"):
		position = Vector2.ZERO
		velocity = Vector2.ZERO

	if Input.is_action_pressed("stick"):
		sticking_to_surface = true
	if event.is_action_released("stick"):
		sticking_to_surface = false
