extends CharacterBody3D
#controller vars
@export var sensitivity = 0.005
@export var walk_speed = 4.0
@export var run_speed = 7.0
@export var crouch_speed = 1.0
@export var jump_height = 4.5
@export var gravity = 9.8
var SPEED

#special vars
var is_sprinting = false
var is_crouching = false
var in_air_momentum = true
@export var slow_speed = 3
@export var extra_jumps = 1
var temp_extra_jumps = extra_jumps
@export var dashtime = 0.5
var dashtime_temp = dashtime
@export var can_dash = true
var is_dashing = false

#bob vars
@export var bob_freq = 2.0
@export var bob_amp = 0.11
@export var t_bob = 0.0




#onready vars
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var collisionshape = $CollisionShape3D
@onready var mesh = $MeshInstance3D


#captures mouse
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#controlls camera
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

#PHYSICS PROCESS
func _physics_process(delta):
	
	if Input.is_action_just_pressed("esc"):
		if not Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	#dashing
	dashtime_temp = dashtime_temp + 0.007
	if dashtime_temp > dashtime:
		dashtime_temp = dashtime
	
	if dashtime_temp < 0:
		is_dashing = false
	
	#sprint and crouch handlingawd sad
	if is_sprinting == true:
		SPEED = run_speed
	else:
		if is_crouching == true:
			SPEED = crouch_speed
		else:
			if is_dashing == true:
				SPEED = run_speed * 2
			else:
				SPEED = walk_speed
			
	if is_dashing == false:
		if Input.is_action_pressed("shift"):
			
			is_sprinting = true
			is_crouching = false
			if Input.is_action_just_pressed("dash") and dashtime_temp + 0.1 > dashtime:
				is_dashing = true
		else:
			is_sprinting = false
		
	#slow speed handling
	if is_dashing == true:
		is_sprinting = false
		dashtime_temp = dashtime_temp - 0.01
		slow_speed = 0
	
	if is_sprinting == true:
		slow_speed = 1
	else:
		if is_crouching == true:
			slow_speed = 6
		else:
			if slow_speed > 4:
				slow_speed = 5
	slow_speed = slow_speed + 0.05
	if slow_speed > 4:
		slow_speed = 4
#PLATFORMING

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta



	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		temp_extra_jumps = extra_jumps
		velocity.y = jump_height
	if Input.is_action_just_pressed("jump") and not is_on_floor() and temp_extra_jumps > 0:
		velocity.y = jump_height
		temp_extra_jumps = temp_extra_jumps - 1
		
	



	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if in_air_momentum == true:
		if is_on_floor() == true:
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = lerp(velocity.x, direction.x * SPEED, delta * slow_speed)
				velocity.z = lerp(velocity.z, direction.z * SPEED, delta * slow_speed)
	
	else:
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * slow_speed)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * slow_speed)
			

	move_and_slide()
	
	
	
	#head bob
	
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos
	
