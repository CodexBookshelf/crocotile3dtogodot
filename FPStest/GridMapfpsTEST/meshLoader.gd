extends Node

export(String, FILE) var meshFile
export(String, FILE) var uvAnimationFile

var mdt = MeshDataTool.new()

var objParse = load("res://ObjParse.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var meshInstance = MeshInstance.new()
	var mesh = objParse.load_obj( meshFile )
	
	#var mesh = load( meshFile )
	meshInstance.set_mesh(mesh)
	self.add_child(meshInstance)
	
	if( uvAnimationFile != '' ):
		meshInstance.set_script( load('res://uvAnimation.gd') )
		meshInstance.uvAnimationFile = uvAnimationFile
		meshInstance._ready()
		meshInstance.set_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
