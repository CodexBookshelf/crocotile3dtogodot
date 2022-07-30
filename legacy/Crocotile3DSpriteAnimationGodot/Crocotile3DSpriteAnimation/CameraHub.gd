extends Spatial


var current_target = null
var sensitivity = 0.1

var anchor2d = Vector2()
var target2d = Vector2()
var anchor = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	#$yGimbal/xGimbal/Camera.current = true
	#$yGimbal.rotate_y(deg2rad(-10))
	$yGimbal/xGimbal.rotate_x(deg2rad(-30))


func _process(delta):
	# check if we need to acquire a new target
	if not is_instance_valid(current_target):
	# we have no target, find one
		var candidates = get_tree().get_nodes_in_group("camera_target")
		print(candidates)
		if candidates.size() >= 1:
			setTarget( candidates[0] )
			
	# position the camera to the target
	if is_instance_valid(current_target):
		#transform.origin = current_target.transform.origin
#		global_transform.origin = lerp( global_transform.origin, current_target.global_transform.origin, 0.2 )
		
		target2d = Vector2(current_target.global_transform.origin.x,current_target.global_transform.origin.y)
		
		
		#anchor2d = lerp( anchor2d, target2d, 0.1 )
		
		if( anchor2d.distance_to( target2d ) > 1 ):
			var dir = target2d.direction_to( anchor2d )
			anchor2d = target2d + dir * 1
		
		#handle slight shift when not moving, based on direction player is facing
		if( current_target.direction.length() == 0 ):
			var extra2d = target2d
			extra2d.x += 1 if current_target.mirrored else -1
			anchor2d = lerp( anchor2d, extra2d, 0.005 )
		
		
		anchor.x = anchor2d.x
		anchor.y = anchor2d.y
		anchor.z = current_target.global_transform.origin.z

func _physics_process(delta):
	if is_instance_valid(current_target):
		#transform.origin = current_target.transform.origin
		global_transform.origin = lerp( global_transform.origin, anchor, 0.1 )
		
		
		var targetTransform = $yGimbal/xGimbal/Camera.global_transform.looking_at( current_target.global_transform.origin, Vector3(0,1,0) )
		var originalTransform = $yGimbal/xGimbal/Camera.global_transform
		
		$yGimbal/xGimbal/Camera.global_transform = originalTransform.interpolate_with( targetTransform, 0.05 )
		
		#$yGimbal.rotate_y(-lerp(0,sensitivity,event.relative.x*0.1))
	
func _unhandled_input(event):
	"""if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$yGimbal.rotate_y(-lerp(0,sensitivity,event.relative.x*0.1))
		$yGimbal/xGimbal.rotate_x(lerp(0,sensitivity,event.relative.y*0.1))"""

func setTarget( target ):
	current_target = target
	
	anchor2d = Vector2(current_target.global_transform.origin.x,current_target.global_transform.origin.y)
	anchor = current_target.global_transform.origin
