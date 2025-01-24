extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

const GRAVITY = 200.0
const WALK_SPEED = 200

func _physics_process(delta):
	velocity.y += delta * GRAVITY

	if Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  WALK_SPEED
	else:
		velocity.x = 0

	var pre_velocity = velocity.length()

	while true:
		var kinematic_collision = move_and_collide(velocity * delta)
		if not kinematic_collision:
			break

		velocity = kinematic_collision.get_remainder()
		velocity.y *= -1

	velocity = velocity.normalized() * pre_velocity
