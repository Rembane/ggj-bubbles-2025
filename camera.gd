extends Camera2D

@export var object: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if object:
		position = position.lerp(object.position, 5 * delta)

	if position.distance_squared_to(object.position) > 250000:
		position = object.position
