extends MeshInstance


# Declare member variables here. Examples:
var mdt = MeshDataTool.new()

var file = File.new()
export (String, FILE) var uvAnimationFile
#var uvAnimationFile = 'res://sceneObj/uvAnimation.txt'

var uvAnimation
var uvX = []

var elapsedTime = 0

# Called when the node enters the scene tree for the first time.
func _ready():
		
	file.open(uvAnimationFile, file.READ)
	uvAnimation = JSON.parse( file.get_as_text() ).result
	file.close()
	
	var startIndex = 0
	var vCount = 0
	for s in range( self.get_surface_material_count() ):
		mdt.create_from_surface(mesh, s)
		startIndex += vCount
		vCount = mdt.get_vertex_count()
		
		for i in range( mdt.get_vertex_count() ):
			var uv = mdt.get_vertex_uv(i)
			if( uv.x >= 100 ):
				var animationIndex = uv.x-100
				var uvIndex = floor(abs(uv.y-1) / 100)
				var custom = (abs(uv.y-1) - uvIndex*100)
				uvIndex -= 1
				
				#print(uvIndex,'  ',custom)
				
				var action = uvAnimation[ animationIndex ]
				var duration = 0
				for frame in action.frame:
					duration += frame.duration
					
				uvX.push_back( { 
					'vertexIndex': startIndex+i, 
					'animationIndex': animationIndex, 
					'uvIndex': uvIndex, 
					'custom': custom, 
					'currentFrame': 0,
					'duration': duration
				} )
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsedTime = OS.get_ticks_msec() / 1000.0	#must be float in order to get precise time
	var updateUVs = false
	
	
	for vertex in uvX:
		var action = uvAnimation[ vertex.animationIndex ]
		var startTime = action.custom[ vertex.custom ]
		var f = 0
		var actionTime = fmod( elapsedTime + startTime, vertex.duration )
		
		var duration = 0
		for frame in action.frame:
			duration += frame.duration
			if( duration > actionTime ): break
			f += 1
			
		if( vertex.currentFrame != f ):
			vertex.currentFrame = f
			updateUVs = true
	
	
	if( updateUVs ):
		var matArray = []
		var startIndex = 0
		var vCount = 0
		
		for s in range( self.get_surface_material_count() ):
			matArray.push_back( self.get_surface_material(s) )
		for s in range( self.get_surface_material_count() ):
			mdt.create_from_surface(mesh, 0)
			startIndex += vCount
			vCount = mdt.get_vertex_count()
			
			for vertex in uvX:
				if( vertex.vertexIndex >= startIndex && vertex.vertexIndex < startIndex+vCount ):
					var v = vertex.vertexIndex - startIndex
					var f = vertex.currentFrame
					var uv = Vector2(
						uvAnimation[ vertex.animationIndex ].frame[ f ].uv[ vertex.uvIndex ].x,
						1-uvAnimation[ vertex.animationIndex ].frame[ f ].uv[ vertex.uvIndex ].y
						)
					mdt.set_vertex_uv( v, uv )
			
			mesh.surface_remove(0)
			mdt.commit_to_surface(mesh)
			self.set_surface_material( self.get_surface_material_count()-1, matArray[s] )
