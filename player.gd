extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$VelocityMeter.clear_points()
	$VelocityMeter.add_point( Vector2(0, 0) )
	$VelocityMeter.add_point( velocity )
	$VelocityMeter.global_rotation = 0
	
	$InputDisplay.clear_points()
	$InputDisplay.add_point( Vector2(0, 0) )
	$InputDisplay.add_point( input * 100 )
	$InputDisplay.global_rotation = 0
	
const GRAVITY = 500.0
const WALK_SPEED = 3000
const DASH_SPEED = 1000
const BORINGNESS = 0.3
var input = Vector2()
var surface_normal = Vector2.UP

func _physics_process(delta):
	input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity *= 0.99
	

	var kinematic_collision = move_and_collide(velocity * delta)
	if kinematic_collision:
		surface_normal = kinematic_collision.get_normal()
		velocity -= velocity.project(surface_normal) #Cancel movement in normal direction
		var normal_input = input.project(surface_normal.orthogonal())
		velocity += normal_input * WALK_SPEED * delta #Walk along plane
		
		velocity *= 0.8 # Friction
		velocity -= surface_normal * GRAVITY * delta # Sticky surfaces
		
		if kinematic_collision.get_collider().get_meta("danger", false):
			reset()
	else:
		velocity.y += GRAVITY * delta
		velocity += input * (WALK_SPEED / 10) * delta #Walk along plane

func _input(event):
	if event.is_action_pressed("dash"):
		velocity = input.normalized() * DASH_SPEED
	elif event.is_action_pressed("reset"):
		reset()

func reset():
		position = Vector2.ZERO
		velocity = Vector2.ZERO
