extends AnimationTree

"""
If you are more comfortable using an AnimationTree, below is some code that sets up a basic tree via gdscript.
Since the animations are being loaded at runtime, this is necessary.
The benefit of this is that you don't have to fuss with all the panels/windows/nodes in the editor.
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#tree = AnimationTree.new()
	#add_child(tree)
	#anim_player = $AnimationPlayer.get_path()
	
	var root = AnimationNodeStateMachine.new()
	tree_root = root
	
	addState( 'idle' )
	addState( 'walk' )
	addState( 'jump' )
	addState( 'fall' )
	
	addTransition( 'idle', 'walk' )
	addTransition( 'walk', 'idle' )
	addTransition( 'idle', 'jump' )
	addTransition( 'walk', 'jump' )
	addTransition( 'jump', 'fall' )
	
	active = true
	tree_root.set_start_node('idle')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func addState( animation ):
	
	var anim = AnimationNodeAnimation.new()
	anim.animation = animation
	
	var blend = AnimationNodeBlendSpace2D.new()
	blend.blend_mode = 1
	blend.add_blend_point(anim, Vector2(-1,0) )
	blend.add_blend_point(anim, Vector2(1,0) )
	
	tree_root.add_node(animation, blend)

func addTransition( from, to, switchMode=0 ):
	
	var transition = AnimationNodeStateMachineTransition.new()
	transition.switch_mode = switchMode
	
	tree_root.add_transition( from, to, transition )
	
	pass
