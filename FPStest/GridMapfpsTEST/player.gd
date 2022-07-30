extends KinematicBody

const MOUSE_SENSITIVITY: float = 0.2
const MOVE_SPEED: float = 3.0
const GRAVITY_ACCELERATION: float = 9.8
const JUMP_FORCE: float = 5.4

onready var look_pivot: Spatial = $LookPivot

var input_move: Vector3 = Vector3()
var gravity_local: Vector3 = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-1 * event.relative.x * MOUSE_SENSITIVITY))
		look_pivot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		look_pivot.rotation.x = clamp(look_pivot.rotation.x, deg2rad(-90), deg2rad(90))

func _physics_process(delta):
	input_move = get_input_direction() * MOVE_SPEED
	if not is_on_floor():
		gravity_local += GRAVITY_ACCELERATION * Vector3.DOWN * delta
	else:
		gravity_local = GRAVITY_ACCELERATION * -get_floor_normal() * delta
	
	if Input.is_action_just_pressed("jump"):
		gravity_local = Vector3.UP * JUMP_FORCE

	move_and_slide(input_move + gravity_local, Vector3.UP)
	

func get_input_direction() -> Vector3:
	var z: float = (
		Input.get_action_strength("forward") - Input.get_action_strength("back")
	)
	var x: float = (
		Input.get_action_strength("left") - Input.get_action_strength("right")
	)
	return transform.basis.xform(Vector3(x,0,z)).normalized()
