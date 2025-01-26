extends StaticBody2D

func _physics_process(delta: float) -> void:
	constant_linear_velocity = constant_linear_velocity.lerp(Vector2.ZERO, 5 * delta)
	if constant_linear_velocity.length_squared() < 10000:
		queue_free()
	else:
		position += constant_linear_velocity * delta
