extends StaticBody2D

func _physics_process(delta: float) -> void:
	constant_linear_velocity = constant_linear_velocity.lerp(Vector2.ZERO, 0.05)
	if constant_linear_velocity.length() < 0.25:
		queue_free()
	else:
		position += constant_linear_velocity * delta
