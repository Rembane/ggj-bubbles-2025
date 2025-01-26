extends CharacterBody2D

const SFX_DASH = preload("res://assets/sound/Dash.wav")
const SFX_RESPAWN = preload("res://assets/sound/Pick_up_item.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2()
	$Wizard.play(&"default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $VelocityMeter:
		$VelocityMeter.clear_points()
		$VelocityMeter.add_point(Vector2.ZERO)
		$VelocityMeter.add_point(gravity_momentum)
		$VelocityMeter.add_point(velocity)

	if $InputDisplay:
		$InputDisplay.clear_points()
		$InputDisplay.add_point(Vector2.ZERO)
		$InputDisplay.add_point(input * 100)

const GRAVITY = Vector2(0, -30.0)
const WALK_SPEED = 500
const DASH_SPEED = 3000
const BORINGNESS = 0.3

var reset_timer = 0
var respawn_point = Vector2.ZERO
var respawn_angle = 0.0

var stickiness = 1.2
var dashes = 2

var input = Vector2()
var surface_normal = Vector2.UP
var gravity_momentum = Vector2.ZERO
var movement_momentum = Vector2.ZERO

func _physics_process(delta):
	input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	gravity_momentum = gravity_momentum.lerp(Vector2.ZERO, 0.1 * delta) # Terminal Velocity
	movement_momentum = movement_momentum.lerp(Vector2.ZERO, 2 * delta)

	velocity = movement_momentum.limit_length(1500) + gravity_momentum

	var kinematic_collision = move_and_collide(velocity * delta)
	if kinematic_collision:
		surface_normal = kinematic_collision.get_normal()
		var offset = Vector2(0, $CollisionShape2D.shape.radius * 2) + kinematic_collision.get_position()
		dashes = 2

		if kinematic_collision.get_collider().get_meta("sticky", false):
			velocity -= velocity.project(surface_normal) #Cancel movement in normal direction

			if Input.is_action_pressed("set_respawn"):
				reset_timer += delta

			if reset_timer > 0.5:
				respawn_point = kinematic_collision.get_position()
				$AudioStreamPlayer2D.set_stream(SFX_RESPAWN)
				$AudioStreamPlayer2D.play()
				reset_timer = 0
				if $"../NormalDisplay":
					$"../NormalDisplay".clear_points()
					$"../NormalDisplay".add_point(offset)
					$"../NormalDisplay".add_point(offset + surface_normal * 100)

			if Input.is_action_pressed("stick"):
				if stickiness > 0:
					var normal_input = input.project(surface_normal.orthogonal())
					movement_momentum = normal_input * WALK_SPEED # Walk along plane
					gravity_momentum = -surface_normal * (250 + stickiness) * delta # Sticky surfaces
					stickiness -= (1 + normal_input.length_squared()) * delta

					$Wizard.rotation = -surface_normal.angle_to(Vector2.UP)
					if normal_input.angle_to(surface_normal) < 0:
						$Wizard.flip_h = true
					else:
						$Wizard.flip_h = false
				else:
					gravity_momentum += surface_normal.project(GRAVITY.orthogonal()) * 10
			else:
				gravity_momentum = gravity_momentum.bounce(surface_normal) * 0.1
				movement_momentum = movement_momentum.bounce(surface_normal) * 0.1

		elif kinematic_collision.get_collider().get_meta("bouncy", false):
			gravity_momentum = gravity_momentum.bounce(surface_normal) * 1.3
			movement_momentum = movement_momentum.bounce(surface_normal) * 1.3
		elif kinematic_collision.get_collider().get_meta("danger", false):
			reset()
	else:
		gravity_momentum += GRAVITY * delta
		movement_momentum += input * (WALK_SPEED / 10) * delta
		reset_timer = 0

func _input(event):
	if event.is_action_pressed("dash"):
		input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input != Vector2.ZERO and dashes > 0:
			movement_momentum = input.normalized() * DASH_SPEED
			gravity_momentum = Vector2.ZERO
			dashes -= 1
			stickiness = 1.2
			$Wizard.rotation = -input.angle_to(Vector2.UP)

			$AudioStreamPlayer2D.set_stream(SFX_DASH)
			$AudioStreamPlayer2D.play()
	elif event.is_action_pressed("reset"):
		$AudioStreamPlayer2D.set_stream(SFX_RESPAWN)
		$AudioStreamPlayer2D.play()
		reset()
	elif event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_released("set_respawn"):
		reset_timer = 0

func reset():
	position = respawn_point
	gravity_momentum = Vector2.ZERO
	movement_momentum = Vector2.ZERO
	velocity = Vector2.ZERO
	stickiness = 1.2
	dashes = 2
