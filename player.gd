extends CharacterBody2D

enum {NO_STICK, INTENT_TO_STICK, STICKING_TO_SURFACE}
const GRAVITY = 200.0
const WALK_SPEED = 2000
const BORINGNESS = 0.8
var stickiness_state_machine = NO_STICK
var last_collision = null
var outer_collision_overlaps = null

func _physics_process(delta):
	if stickiness_state_machine != STICKING_TO_SURFACE:
		velocity += Input.get_vector("move_left", "move_right", "move_up", "move_down") \
				* WALK_SPEED * delta

	var kinematic_collision = move_and_collide(velocity * delta)
	if kinematic_collision:
		match stickiness_state_machine:
			INTENT_TO_STICK, STICKING_TO_SURFACE:
				stickiness_state_machine = STICKING_TO_SURFACE
				velocity = Vector2.ZERO
				last_collision = kinematic_collision.get_collider()
			_:
				velocity = velocity.bounce(kinematic_collision.get_normal()) \
						* BORINGNESS
	else:
		if stickiness_state_machine in [STICKING_TO_SURFACE, INTENT_TO_STICK] \
				and last_collision != null and outer_collision_overlaps == last_collision:
			stickiness_state_machine = STICKING_TO_SURFACE
			velocity = Vector2.ZERO

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
			_:
				pass
	elif event.is_action_released("stick"):
		stickiness_state_machine = NO_STICK

func _on_outer_collision_area_body_entered(body: Node2D) -> void:
	outer_collision_overlaps = body

func _on_outer_collision_area_body_exited(body: Node2D) -> void:
	if body == outer_collision_overlaps and outer_collision_overlaps == last_collision:
		outer_collision_overlaps = null
		last_collision = null
