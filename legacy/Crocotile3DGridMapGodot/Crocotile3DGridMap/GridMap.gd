extends GridMap

export(String, FILE) var mapFile

# Called when the node enters the scene tree for the first time.
func _ready():
	loadCells()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func loadCells():
	var path = mapFile
	
	var file = File.new()
	if file.file_exists(path):
		var error = file.open(path, File.READ)
		if( error == OK ):
			var data = JSON.parse( file.get_as_text() ).result
			file.close()
			
			self.visible = false
			self.clear()
			self.set_cell_size( Vector3( data.size.x, data.size.y, data.size.z ) )
			for c in data.cells:
				self.set_cell_item( c[0], c[1], c[2], c[3] )
				#print(c)
