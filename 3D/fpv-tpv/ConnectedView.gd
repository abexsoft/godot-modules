var player
var rotation_helper
var camera

var dir = Vector3()
var rotate_x_rad = 0
var rotate_y_rad = 0
var rotate_z = 0

var MOUSE_SENSITIVITY = 0.05
var ROTATION_X_SENSITIVITY = 80
var ROTATION_Y_SENSITIVITY = 80
var ROTATION_Z_SENSITIVITY = 1

var RESET_ROTATION_HELPER_SPEED = 0.05

enum {GROUNDING_MODE, FLYING_MODE}
var mode

enum {FP_VIEW, TP_VIEW}
var view

func ready(player):
	self.player = player
	self.mode = GROUNDING_MODE
	self.view = TP_VIEW
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation_helper = player.get_node("RotationHelper")
	camera  = player.get_node("RotationHelper/Camera")
	# just for testing
#	player.linear_damp = 0.8
#	player.angular_damp = 0.8

func input(event):
	get_move_input(event)
	get_rotation_input(event)

func integrate_forces(state):
	move_player(state)
	rotate_player(state)

func change_view():
	if view == TP_VIEW:
		print("Changed into FPV")
		camera.set_translation(Vector3(0, 0, 1))
		view = FP_VIEW
	else:
		print("Changed into TPV")
		camera.set_translation(Vector3(-2, 1.5, -4))
		view = TP_VIEW

func change_mode():
	if mode == GROUNDING_MODE:
		print("Changed into FLYING_MODE")
		mode = FLYING_MODE
	else:
		print("Changed into GROUNDING_MODE")
		mode = GROUNDING_MODE

func get_move_input(event):
	if Input.is_action_pressed("change_view"):
		change_view()
	
	if Input.is_action_pressed("change_mode"):
		change_mode()
		
	var input_movement_vector = Vector3()
	if Input.is_action_pressed("move_forward"):
		input_movement_vector.z += 1
	if Input.is_action_pressed("move_backward"):
		input_movement_vector.z -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1
	if Input.is_action_pressed("move_up"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_down"):
		input_movement_vector.y -= 1		
	input_movement_vector = input_movement_vector.normalized()	
	
	# make a move direction with player or camera direction.
	# basis represents the direction with 3 axis vector.
	# player forward is z.
	# camera forward is -z.
	dir = Vector3()	
	if mode == GROUNDING_MODE:
		var player_xform = player.get_global_transform()
		dir += player_xform.basis.z * input_movement_vector.z
		dir += -player_xform.basis.x * input_movement_vector.x	
		dir += player_xform.basis.y * input_movement_vector.y	
	else:
		var cam_xform = camera.get_global_transform()
		dir += -cam_xform.basis.z * input_movement_vector.z
		dir += cam_xform.basis.x * input_movement_vector.x	
		dir += cam_xform.basis.y * input_movement_vector.y	
	dir = dir.normalized()	
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func get_rotation_input(event):
	rotate_x_rad = 0
	rotate_y_rad = 0
	rotate_z = 0
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_x_rad = deg2rad(event.relative.y * MOUSE_SENSITIVITY)
		rotate_y_rad = deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1)

	if Input.is_action_pressed("rotate_right"):
		rotate_z = 1
	if Input.is_action_pressed("rotate_left"):
		rotate_z = -1
	if not Input.is_action_pressed("rotate_right") and not Input.is_action_pressed("rotate_left"):
		rotate_z = 0

func move_player(state):
	player.add_central_force(50 * dir)

func reset_rotation_helper():
	var rot_x = rotation_helper.rotation.x	
	if rot_x != 0:
		if abs(rot_x) < RESET_ROTATION_HELPER_SPEED:
			rotation_helper.rotation.x = 0
		else:
			if rot_x > 0:
				rotation_helper.rotation.x -= RESET_ROTATION_HELPER_SPEED
			else:
				rotation_helper.rotation.x += RESET_ROTATION_HELPER_SPEED
		
func rotate_player(state):
	var angular_velocity = Vector3()
	var transform = player.get_global_transform()

	if mode == GROUNDING_MODE:
		rotation_helper.rotate_x(rotate_x_rad)
		angular_velocity += rotate_y_rad * transform.basis.y * 100
		# clamp
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot		
	else:
		reset_rotation_helper()
		angular_velocity += rotate_x_rad * transform.basis.x * 100	
		angular_velocity += rotate_y_rad * transform.basis.y * 100
		if rotate_z != 0:
			angular_velocity += rotate_z * transform.basis.z * state.get_step() * 100
	state.angular_velocity = angular_velocity
	
	rotate_x_rad = 0
	rotate_y_rad = 0
#	rotate_z = 0
	
	
