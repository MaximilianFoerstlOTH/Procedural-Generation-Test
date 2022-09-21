extends KinematicBody

var speed = 10
var h_acceleration = 6
var normal_acceleration = 6
var gravity = 20
var jump = 10

var mouse_sensitivity = 0.1

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

onready var head = $Head
onready var groundCheck = $GroundCheck

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
		
func _process(delta):
	print(Performance.get_monitor(Performance.TIME_FPS))

func _physics_process(delta):
	
	direction = Vector3()
	
	
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
	else: 
		gravity_vec = Vector3.ZERO
	if Input.is_action_pressed("move_up") and (groundCheck.is_colliding() or is_on_floor()):
		gravity_vec = Vector3.UP * jump
		
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	direction = direction.normalized()
	direction.y = gravity_vec.y
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	movement = move_and_slide(movement, Vector3.UP)
