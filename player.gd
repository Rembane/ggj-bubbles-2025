extends CharacterBody2D

const SFX_DASH = preload("res://assets/sound/Dash.wav")
const SFX_RESPAWN = preload("res://assets/sound/Pick_up_item.wav")
const SPEED_BUBBLES = preload("res://speed_bubbles.tscn")

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
const STOP_SPAWNING_BUBBLES_VELOCITY = 50000

var reset_timer = 0
var respawn_point = Vector2.ZERO
var respawn_angle = 0.0

var rng = RandomNumberGenerator.new()

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

	velocity = movement_momentum.limit_length(1000) + gravity_momentum

	var kinematic_collision = move_and_collide(velocity * delta)
	if kinematic_collision:
		var collision_location = Vector2(0, $CollisionShape2D.shape.radius * 2) + kinematic_collision.get_position()
		var tilemaplayer: TileMapLayer = kinematic_collision.get_collider()
		surface_normal = kinematic_collision.get_normal()
		position -= kinematic_collision.get_depth() * surface_normal
		var map_coord: Vector2 = tilemaplayer.local_to_map(kinematic_collision.get_position() - surface_normal)
		var td: TileData = tilemaplayer.get_cell_tile_data(map_coord)
		if not td:
			return
		dashes = 2

		if td.get_custom_data("sticky"):
			velocity -= velocity.project(surface_normal) #Cancel movement in normal direction
			gravity_momentum -= gravity_momentum.project(surface_normal) #Cancel movement in normal direction
			movement_momentum -= movement_momentum.project(surface_normal) #Cancel movement in normal direction
			if Input.is_action_pressed("set_respawn"):
				if reset_timer == 0:
					$Wizard.play(&"magic")
				reset_timer += delta

			if reset_timer > 0.5:
				respawn_point = kinematic_collision.get_position()
				$AudioStreamPlayer2D.set_stream(SFX_RESPAWN)
				$AudioStreamPlayer2D.play()
				reset_timer = 0
				if $"../NormalDisplay":
					$"../NormalDisplay".clear_points()
					$"../NormalDisplay".add_point(collision_location)
					$"../NormalDisplay".add_point(collision_location + surface_normal * 100)

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
					if normal_input.length_squared() != 0:
						$Wizard.play(&"walk")
					elif $Wizard.animation == &"walk":
						$Wizard.play(&"idle")
				else:
					gravity_momentum += surface_normal.project(GRAVITY.orthogonal()) * 10
					if $Wizard.animation == &"walk":
						$Wizard.play(&"idle")
			else:
				gravity_momentum = gravity_momentum.bounce(surface_normal) * 0.1
				movement_momentum = movement_momentum.bounce(surface_normal) * 0.1
				if $Wizard.animation == &"walk":
					$Wizard.play(&"idle")

		elif td.get_custom_data("bouncy"):
			gravity_momentum = gravity_momentum.bounce(surface_normal) * 1.3
			movement_momentum = movement_momentum.bounce(surface_normal) * 1.3
		elif td.get_custom_data("deadly"):
			reset()
		else:
			velocity -= velocity.project(surface_normal) #Cancel movement in normal direction
			gravity_momentum -= gravity_momentum.project(surface_normal) #Cancel movement in normal direction
			movement_momentum -= movement_momentum.project(surface_normal) #Cancel movement in normal direction
	else:
		gravity_momentum += GRAVITY * delta
		movement_momentum += input * (WALK_SPEED / 10) * delta
		reset_timer = 0

	if velocity.length_squared() >= STOP_SPAWNING_BUBBLES_VELOCITY:
		var speed_bubble = SPEED_BUBBLES.instantiate()
		speed_bubble.position = position
		speed_bubble.constant_linear_velocity = velocity.rotated(rng.randf_range(-0.1, 0.1))
		speed_bubble.set_scale(Vector2.ONE * rng.randf_range(0.15, 0.4))
		add_sibling(speed_bubble)

func _input(event):
	if event.is_action_pressed("dash"):
		input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input != Vector2.ZERO and dashes > 0:
			movement_momentum = input.normalized() * DASH_SPEED
			gravity_momentum = Vector2.ZERO
			dashes -= 1
			stickiness = 1.2
			$Wizard.rotation = -input.angle_to(Vector2.UP)
			$Wizard.play(&"jump")

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
		$Wizard.play(&"idle")
	elif event.is_action_pressed("screenshot"):
		var date = Time.get_date_string_from_system().replace(".","_") 
		var time :String = Time.get_time_string_from_system().replace(":","")
		var screenshot_path = "user://" + "screenshot_" + date+ "_" + time + ".jpg" # the path for our screenshot.
		var image = get_viewport().get_texture().get_image() # We get what our player sees
		image.save_jpg(screenshot_path)

func reset():
	position = respawn_point
	gravity_momentum = Vector2.ZERO
	movement_momentum = Vector2.ZERO
	velocity = Vector2.ZERO
	stickiness = 1.2
	dashes = 2
	$Wizard.play(&"idle")

func _on_wizard_animation_finished():
	$Wizard.play("idle")
