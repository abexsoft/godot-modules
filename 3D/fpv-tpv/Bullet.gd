extends RigidBody

var speed = 100

func start(origin, dir, linear_velocity):
	transform.origin = origin
	self.linear_velocity = linear_velocity
	apply_central_impulse(dir * speed)

func _on_Timer_timeout():
	queue_free()	

