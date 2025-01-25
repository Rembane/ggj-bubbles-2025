extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

const GRAVITY = 200.0
const WALK_SPEED = 2000
const BORINGNESS = 0.8

func _physics_process(delta):
	velocity += Input.get_vector("move_left", "move_right", "move_up", "move_down") * WALK_SPEED * delta
	velocity.y -= - GRAVITY * delta 

	var kinematic_collision = move_and_collide(velocity * delta)
	if kinematic_collision:
		velocity = velocity.bounce(kinematic_collision.get_normal()) * BORINGNESS
	else:
		velocity.y += delta * GRAVITY
