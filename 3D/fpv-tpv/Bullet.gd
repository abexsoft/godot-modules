extends RigidBody

var speed = 30

func start(xform, linear_velocity):
	transform.origin = xform.origin
	transform.origin += xform.basis.y * 1
	self.linear_velocity = linear_velocity
	apply_central_impulse(xform.basis.y * speed)

func _on_Timer_timeout():
	queue_free()	

