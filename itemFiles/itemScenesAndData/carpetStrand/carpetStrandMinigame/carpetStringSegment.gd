extends RigidBody2D

var C = 0.005

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var airResistance = -C * linear_velocity.length_squared() * linear_velocity.normalized()
	apply_force(airResistance)
