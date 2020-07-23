extends RigidBody
class_name Player

var ConnectedView = preload("ConnectedView.gd")
var cv

var Bullet = preload("res://Bullet.tscn")
var shoot_flag = false

func init_actions():
	create_keymap("move_forward", KEY_W)
	create_keymap("move_backward", KEY_S)
	create_keymap("move_left", KEY_A)
	create_keymap("move_right", KEY_D)
	create_keymap("move_up", KEY_SPACE)
	create_keymap("move_down", KEY_CONTROL)
	create_keymap("change_mode", KEY_TAB)
	create_keymap("change_view", KEY_F1)
	create_keymap("rotate_left", KEY_Q)
	create_keymap("rotate_right", KEY_E)
	var input_event = InputEventMouseButton.new()
	input_event.button_index = BUTTON_LEFT
	InputMap.add_action("shoot")
	InputMap.action_add_event("shoot", input_event)
	
func create_keymap(action_name, scancode):
	var input_event = InputEventKey.new()
	input_event.scancode = scancode
	InputMap.add_action(action_name)
	InputMap.action_add_event(action_name, input_event)

func _ready():
	init_actions()
	cv = ConnectedView.new()
	cv.ready(self)

func _input(event):
	cv.input(event)
	if event.is_action_pressed("shoot"):
		shoot_flag = true      
				
func _integrate_forces(state):
	cv.integrate_forces(state)
	if shoot_flag:
		shoot()
	
func shoot():
	var b = Bullet.instance()
	b.start($RotationHelper/Bazooka.global_transform, linear_velocity)
	get_parent().add_child(b)
	shoot_flag = false
	print("shoot")


