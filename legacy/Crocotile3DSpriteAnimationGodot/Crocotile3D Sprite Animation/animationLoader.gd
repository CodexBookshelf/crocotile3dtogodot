extends AnimatedSprite3D

var file = File.new()

export(String, FILE) var animationFile
export(StreamTexture) var imageFile

var atlasTexture
var spriteFrames = SpriteFrames.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	frames = spriteFrames
	
	var parent = self.get_parent()
	var animationPlayer = parent.get_node('AnimationPlayer')
	#print(animationPlayer)
	
	file.open(animationFile, file.READ)
	var data = JSON.parse( file.get_as_text() ).result
	file.close()
	
	for animation in data:
		frames.add_animation( animation.name )
		
		var anim = Animation.new()
		var track_index = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track_index, "AnimatedSprite3D:animation")
		anim.track_set_interpolation_type(track_index, 0)		#nearest neighbor interpolation
		anim.track_insert_key(track_index, 0, animation.name)
		track_index = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track_index, "AnimatedSprite3D:frame")
		anim.track_set_interpolation_type(track_index, 0)		#nearest neighbor interpolation
		
		var f = 0
		var duration = 0
		for frame in animation.frame:
			anim.track_insert_key(track_index, duration, f)
			duration += frame.duration
			
			atlasTexture = AtlasTexture.new()
			atlasTexture.atlas = imageFile
			
			var left = 999999
			var top = 999999
			var right = -999999
			var bottom = -999999
			
			for uv in frame.uv:
				left = min( left, uv.x )
				top = min( top, 1-uv.y )
				right = max( right, uv.x )
				bottom = max( bottom, 1-uv.y )
			
			left *= imageFile.get_width()
			right *= imageFile.get_width()
			top *= imageFile.get_height()
			bottom *= imageFile.get_height()
			
			atlasTexture.region = Rect2(left,top,right-left,bottom-top)
			frames.add_frame( animation.name, atlasTexture, f )
			f += 1
	
		#frames.set_animation_loop(animation.name, true)
		#frames.set_animation_speed(animation.name, 0.0)
		
		anim.length = duration
		#In crocotile, you can set the Start time of a tile(bottom of UV panel). This will be saved to the custom array.
		if( animation.custom.size() > 1 || animation.custom[0] > 0 ): anim.loop = true
		
		animationPlayer.add_animation( animation.name, anim )
		animationPlayer.play(animation.name)
		#print(animationPlayer.current_animation_length)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
