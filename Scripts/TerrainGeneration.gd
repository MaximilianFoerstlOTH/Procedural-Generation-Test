extends MultiMeshInstance
var prev = 0
var instanceId := 0
var gridsize = 2
var block = preload("res://Assets/World/Block.tscn")
var worldsize = 300
var mesh_count := 0
var blocks = []
func _ready():  # Runs when scene is initialized
	for x in range(0,worldsize):
		var _arr = []
		blocks.append([])
		for _y in range(0,worldsize):
			blocks[x].append(null)
			
	mesh_count = worldsize * worldsize 
	
	self.multimesh.instance_count = mesh_count
	
	generateWorld()
	#fillHoles()
	
	
#TODO LÖSCHEN WENN NICHT MEHR BENÖTIGT 
func createChunk(chunkX, chunkY):
	var y = 0
	for x in range(0+chunkX*16,16+chunkX*16,1):
		var h = y
		for z in range(0+chunkY*16,16+chunkY*16,1):
			setBlock_and_add_to_array(x,y,z)
			y = y +1
		y = h +1


func setBlock_and_add_to_array(gridX, gridY, gridZ):
	setBlock(gridX, gridY, gridZ)
	blocks[gridX][gridZ] = gridY
	
func setBlock(gridX, gridY, gridZ):
#	var block_instance = block.instance()
#	var orig = Transform()
#	orig.origin = Vector3(gridX*gridsize,gridY*gridsize,gridZ*gridsize)
#	block_instance.transform = orig
#	add_child(block_instance)
	self.multimesh.set_instance_transform(instanceId, Transform(Basis(), Vector3(gridX, gridY, gridZ)))
	instanceId = instanceId + 1
	


		
#Check if gridsize is further away than 2 (neighbors)
func fillHoles():
	for x in range(worldsize):
		var lasty = null
		for z in range(worldsize):
			if lasty == null:
				lasty = blocks[x][z]
				continue
			if blocks[x][z] == null:
				continue
			if lasty-1 > blocks[x][z] :
				for i in range(blocks[x][z]+1, lasty):
					setBlock(x,i,z)
			if lasty+1 < blocks[x][z] :
				for i in range(lasty+1, blocks[x][z]):
					setBlock(x,i,z)
			lasty = blocks[x][z]
	for z in range(worldsize):
		var lasty = null
		for x in range(worldsize):
			if lasty == null:
				lasty = blocks[x][z]
				continue
			if blocks[x][z] == null:
				continue
			if lasty-1 > blocks[x][z] :
				for i in range(blocks[x][z]+1, lasty):
					setBlock(x,i,z)
			if lasty+1 < blocks[x][z] :
				for i in range(lasty+1, blocks[x][z]):
					setBlock(x,i,z)
			lasty = blocks[x][z]			
	
func generateWorld():
	var noise = OpenSimplexNoise.new()
	randomize()
	noise.seed = randi()
	noise.period = 130.0
	noise.persistence = 0.8
	for x in range(worldsize):
		for z in range(worldsize):
			var y = noise.get_noise_2d(x,z)+1
			y = floor(y*50)
			setBlock_and_add_to_array(x,y,z)
			
