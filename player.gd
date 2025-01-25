extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$VelocityMeter.clear_points()
	$VelocityMeter.add_point(Vector2.ZERO)
	$VelocityMeter.add_point(velocity)
	
	$InputDisplay.clear_points()
	$InputDisplay.add_point(Vector2.ZERO)
	$InputDisplay.add_point(input * 100)
	
const GRAVITY = 500.0
const WALK_SPEED = 400
const DASH_SPEED = 3000
const BORINGNESS = 0.3
var input = Vector2()
var surface_normal = Vector2.UP
var gravity_momentum = Vector2.ZERO
var movement_momentum = Vector2.ZERO

func _physics_process(delta):
	input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	gravity_momentum = gravity_momentum.lerp(Vector2.ZERO, 0.1 * delta) # Terminal Velocity
	movement_momentum = movement_momentum.lerp(Vector2.ZERO, 2 * delta)

	velocity = movement_momentum.limit_length(3000) + gravity_momentum
	
	var kinematic_collision = move_and_collide(velocity * delta)
	if kinematic_collision:
		surface_normal = kinematic_collision.get_normal()
		var offset = Vector2(0, $CollisionShape2D.shape.radius * 2)
		$"../NormalDisplay".clear_points()
		$"../NormalDisplay".add_point(kinematic_collision.get_position() + offset)
		$"../NormalDisplay".add_point(kinematic_collision.get_position() + offset + surface_normal * 100)
		
		if kinematic_collision.get_collider().get_meta("sticky", false):
			velocity -= velocity.project(surface_normal) #Cancel movement in normal direction
			var normal_input = input.project(surface_normal.orthogonal())
			movement_momentum = normal_input * WALK_SPEED # Walk along plane
			
			gravity_momentum = -surface_normal * GRAVITY * delta # Sticky surfaces
			
		elif kinematic_collision.get_collider().get_meta("bouncy", false):
			gravity_momentum = gravity_momentum.bounce(surface_normal) * 1.3
			movement_momentum = movement_momentum.bounce(surface_normal) * 1.3
		elif kinematic_collision.get_collider().get_meta("danger", false):
			reset()
	else:
		gravity_momentum.y += GRAVITY * delta
		movement_momentum += input * (WALK_SPEED / 10) * delta
	

func _input(event):
	if event.is_action_pressed("dash"):
		movement_momentum = input.normalized() * DASH_SPEED
		gravity_momentum = Vector2.ZERO
	elif event.is_action_pressed("reset"):
		reset()

func reset():
		position = Vector2.ZERO
		velocity = Vector2.ZERO
