extends RigidBody2D

# Adjustable properties
@export_range(0.1, 10.0, 0.1) var min_scale: float = 0.5      # Minimum bubble size
@export_range(0.1, 10.0, 0.1) var max_scale: float = 2.0      # Maximum bubble size
@export_range(0.01, 1.0, 0.01) var scale_step: float = 0.1    # Step size for increasing/decreasing bubble size
@export_range(10.0, 1000.0, 10.0) var base_buoyancy: float = 200.0  # Base buoyancy

# Current buoyancy
var buoyancy = base_buoyancy
var current_scale: float = 1.0  # Track the current scale of the bubble

# References to the child nodes
var sprite: Sprite2D
var collision_shape: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the child sprite node
	sprite = $BubbleSprite
	if sprite == null:
		print("Error: Sprite2D node not found as a child!")
	
	# Get the child collision shape node
	collision_shape = $BubbleCollisionShape
	if collision_shape == null:
		print("Error: CollisionShape2D node not found as a child!")
	
	# Initialize scale
	current_scale = sprite.scale.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Increase bubble size with RB button
	if Input.is_action_pressed("ui_rb"):
		increase_bubble_size()

	# Decrease bubble size with LB button
	if Input.is_action_pressed("ui_lb"):
		decrease_bubble_size()

# Function to increase bubble size
func increase_bubble_size():
	if current_scale < max_scale:
		current_scale += scale_step
		update_scale()

# Function to decrease bubble size
func decrease_bubble_size():
	if current_scale > min_scale:
		current_scale -= scale_step
		update_scale()

# Function to update the scale of the sprite and collision shape
func update_scale():
	if sprite:
		sprite.scale = Vector2(current_scale, current_scale)
	if collision_shape:
		var shape = collision_shape.shape
		if shape is CircleShape2D:
			shape.radius = current_scale * 50  # Adjust this multiplier to match the desired size

# Called during the physics process to apply forces.
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Update buoyancy force based on scale
	apply_buoyancy(state)

# Function to apply buoyancy force
func apply_buoyancy(state: PhysicsDirectBodyState2D):
	# Calculate buoyancy based on the current scale
	buoyancy = base_buoyancy * current_scale

	# Apply an upward force proportional to buoyancy
	var buoyancy_force = Vector2(0, -buoyancy)
	state.apply_central_force(buoyancy_force)
