extends KinematicBody

export var inertia : float = 1

export var jumpHeight : float
export var jumpTimePeak : float
export var jumpTimeDescent : float

onready var jumpVelocity : float = (2.0 * jumpHeight) / jumpTimePeak
onready var jumpGravity : float = (-2.0 * jumpHeight) / (jumpTimePeak * jumpTimePeak)
onready var fallGravity : float = (-2.0 * jumpHeight) / (jumpTimeDescent * jumpTimeDescent)

var gravity = Vector3.DOWN * 0.98
var speed = 5
var airSpeed = 2
var acceleration = 5
var airAcceleration = 2
var jump = false
var jumpSpeed = 25
var spin = 0.1
var direction = Vector3()
var velocity = Vector3()
var floorArray = []

var firstFall = true
var isOnFloor = true

var mirrored = false;

func _ready():
	pass

func _physics_process(delta):
	getInput(delta)
	
	#gravity_resistance will be used to cancel sliding on slopes- note: make sure any modification to velocity doesn't happen afterwards (before move_and_slide)
	var gravity_resistance = get_floor_normal() if is_on_floor() else Vector3.UP
	velocity += gravity_resistance * getGravity() * delta
	
	#velocity.y += getGravity() * delta
	
	var preVelocity = velocity
	
	velocity = move_and_slide(velocity, Vector3.UP, false, 4, PI/4, false)
	
	isOnFloor = onFloor()
	if isOnFloor and jump:
		velocity.y = jumpVelocity
	

func getInput(delta):
	direction = Vector3(0,0,0)
	var vy = velocity.y
	var xz = velocity
	xz.y = 0.0
	
	if Input.is_action_pressed('ui_up'):
		#if !is_on_floor() or $RayCast.is_colliding():
		direction += Vector3(0,0,-1)
	if Input.is_action_pressed('ui_down'):
		direction += Vector3(0,0,1)
	if Input.is_action_pressed('ui_left'):
		direction += Vector3(-1,0,0)
	if Input.is_action_pressed('ui_right'):
		direction += Vector3(1,0,0)

	direction = direction.normalized()
	if is_on_floor():
		if direction.length() > 0:
			xz = xz.linear_interpolate(direction * speed, acceleration * delta)
		else:
			xz = xz.linear_interpolate(direction * speed, acceleration * 2 * delta)
	else:
		xz = xz.linear_interpolate(direction * airSpeed, airAcceleration * delta)
	velocity.x = xz.x
	velocity.z = xz.z
	
	if( direction.length() > 0 && !global_transform.basis.xform(Vector3.FORWARD).is_equal_approx( direction ) ):
		look_at(global_transform.origin + direction, Vector3.UP)
	
	if( direction.x > 0 ): mirrored = false
	elif( direction.x < 0 ): mirrored = true
	
	jump = false
	if( Input.is_action_just_pressed('ui_select') ):
		jump = true
		

func getGravity() -> float:
	return jumpGravity if velocity.y > 0 else fallGravity

func onFloor() -> bool:
	floorArray.push_back(is_on_floor())
	if(floorArray.size() > 3): floorArray.pop_front()
	
	var f = false
	for e in floorArray:
		if(e): f=e
	return f
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#$aim.rotate_y(-lerp(0,spin,event.relative.x*0.1))
		pass
		
