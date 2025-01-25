extends CharacterBody2D

enum {NO_STICK, INTENT_TO_STICK, STICKING_TO_SURFACE, INTENT_TO_UNSTICK}
const GRAVITY = 200.0
const WALK_SPEED = 2000
const BORINGNESS = 0.8
var stickiness_state_machine = NO_STICK

func _physics_process(delta):
	if stickiness_state_machine != STICKING_TO_SURFACE:
		velocity += Input.get_vector("move_left", "move_right", "move_up", "move_down") \
				* WALK_SPEED * delta

	var kinematic_collision = move_and_collide(velocity * delta)
	if kinematic_collision:
		if stickiness_state_machine == INTENT_TO_STICK:
			stickiness_state_machine = STICKING_TO_SURFACE
		if stickiness_state_machine == STICKING_TO_SURFACE:
			velocity = Vector2.ZERO
		else:
			velocity = velocity.bounce(kinematic_collision.get_normal()) * BORINGNESS
	else:
		if stickiness_state_machine != STICKING_TO_SURFACE:
			velocity.y += delta * GRAVITY

func _input(event):
	if event.is_action_pressed("reset"):
		position = Vector2.ZERO
		velocity = Vector2.ZERO
		stickiness_state_machine = NO_STICK

	if event.is_action_pressed("stick"):
		match stickiness_state_machine:
			NO_STICK:
				stickiness_state_machine = INTENT_TO_STICK
			INTENT_TO_UNSTICK:
				stickiness_state_machine = INTENT_TO_STICK
			_:
				pass
	elif event.is_action_released("stick"):
		match stickiness_state_machine:
			INTENT_TO_STICK:
				stickiness_state_machine = INTENT_TO_UNSTICK
			STICKING_TO_SURFACE:
				stickiness_state_machine = INTENT_TO_UNSTICK
			_:
				pass
