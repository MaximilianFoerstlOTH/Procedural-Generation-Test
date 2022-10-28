extends CharacterBody3D

var speed = 30
var h_acceleration = 1
var gravity = 50
var jump = 15
var mouse_sensitivity = 0.1

var move_direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_direction = Vector3()
var _timer = null


@onready var terrain = get_node("../TerrainGeneration")
@onready var head = $Head
@onready var groundCheck = $GroundCheck

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_timer = Timer.new()
	add_child(_timer)

	_timer.connect("timeout",Callable(self,"_on_Timer_timeout"))
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
func _process(_delta):
	#print(Performance.get_monitor(Performance.TIME_FPS))
	pass
	

func _physics_process(delta):
	
	move_direction = Vector3()
	if not is_on_floor():
		gravity_direction += Vector3.DOWN * gravity * delta
	else: 
		gravity_direction = Vector3.ZERO
	if Input.is_action_pressed("move_up") and (groundCheck.is_colliding() or is_on_floor()):
		gravity_direction = Vector3.UP * jump
	if Input.is_action_pressed("move_forward"):
		move_direction -= transform.basis.z
	elif Input.is_action_pressed("move_back"):
		move_direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		move_direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		move_direction += transform.basis.x
		
	move_direction = move_direction.normalized()
	move_direction.y = gravity_direction.y
	h_velocity = h_velocity.lerp(move_direction * speed, h_acceleration)
	movement.z = h_velocity.z + gravity_direction.z
	movement.x = h_velocity.x + gravity_direction.x
	movement.y = gravity_direction.y
	set_velocity(movement)
	set_up_direction(Vector3.UP)
	move_and_slide()
	movement = velocity

func _on_Timer_timeout():
	terrain.createStaticBodies(position)


