extends KinematicBody

var speed = 30
var h_acceleration = 6
var normal_acceleration = 6
var gravity = 50
var jump = 15
var mouse_sensitivity = 0.1

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()
var _timer = null

onready var network = get_node("../Network")
#var position = Vector2()
slave var slave_position = Vector3()
slave var slave_movement = Vector3()

onready var terrain = get_node("../TerrainGeneration")
onready var head = $Head
onready var groundCheck = $GroundCheck

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_timer = Timer.new()
	add_child(_timer)

	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
		
func _process(_delta):
	#print(Performance.get_monitor(Performance.TIME_FPS))
	pass
	

func _physics_process(delta):
	
	direction = Vector3()
	
	if is_network_master():
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
		rset_unreliable('slave_position', transform.origin)
		rset('slave_movement', direction)
		_move(direction);
	else:
		_move(slave_movement)
		transform.origin = slave_position
		
	if get_tree().is_network_server():
		network.update_position(int(name), transform.origin)



func _on_Timer_timeout():
	terrain.createStaticBodies(transform.origin)


func _move(direction):
	direction = direction.normalized()
	direction.y = gravity_vec.y
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	movement = move_and_slide(movement, Vector3.UP)

func init(nickname, start_position, is_slave):
	#$GUI/Nickname.text = nickname
	transform.origin = start_position
	#if is_slave:
		#$Sprite.texture = load('res://player/player-alt.png')
