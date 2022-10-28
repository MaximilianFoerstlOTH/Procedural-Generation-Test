extends MultiMeshInstance3D

var prev = 0
var instanceId := 0
var gridsize = 2
var worldsize = 300
var mesh_count := 0
var blocks = []
var sBodys = []

func _ready():  # Runs when scene is initialized
	initArrays()		
	mesh_count = worldsize * worldsize 
	self.multimesh.instance_count = mesh_count
	generateWorld()
	#fillHoles()
	
func initArrays():
	for x in range(0,worldsize):
		blocks.append([])
		for _y in range(0,worldsize):
			blocks[x].append(null)
	for x in range(0, worldsize):
		sBodys.append([])
		for _y in range(0,worldsize):
			sBodys[x].append(null)


func setBlock_and_add_to_array(gridX, gridY, gridZ):
	setBlock(gridX, gridY, gridZ)
	blocks[gridX][gridZ] = gridY
	
func setBlock(gridX, gridY, gridZ):
	var block_transform = Transform3D(Basis(), Vector3(gridX*gridsize, gridY*gridsize, gridZ*gridsize))
	
	self.multimesh.set_instance_transform(instanceId, block_transform)
	instanceId = instanceId + 1
	

#func deactivateAllColliders():
#	for i in sBodys:
#		for j in i:
#			j.get_child(0).disabled = true
#
#func activateColliders(fromX, toX, fromZ, toZ):
#	deactivateAllColliders()
#	for i in range(fromX, toX):
#		for j in range(fromZ, toZ):
#			if i < 0 or i > worldsize-1:
#				continue
#			if j < 0 or j > worldsize-1: 
#				continue
#			sBodys[i][j].get_child(0).disabled = false

			
func createStaticBodies(s_position:Vector3):
	var posx = floor(s_position.x) / gridsize
	var posz = floor(s_position.z) / gridsize

	var size = 20
	for i in range(posx-size, posx+size):
		for j in range(posz-size, posz+size):
			if i > worldsize-1:
				i = worldsize -1
			if j > worldsize-1: 
				j = worldsize -1
			if sBodys[i][j] == null:
				var s_transform = Transform3D(Basis(), Vector3(i*gridsize, blocks[i][j]*gridsize, j*gridsize))

				var shape = CollisionShape3D.new()
				shape.shape = BoxShape3D.new()
				var sBody = StaticBody3D.new()
				sBody.transform = s_transform
				sBody.collision_layer = 2
				sBody.collision_mask = 1
				sBody.add_child(shape)
				sBodys[i][j]= sBody
				add_child(sBody)

#	for i in range(worldsize):
#		for j in range(worldsize):
#			if i < posx-20 or i > posx +20:
#				if sBodys[i][j] != null:
#					remove_child(sBodys[i][j])
#					sBodys[i][j].queue_free()
#					sBodys[i][j] = null
#			if j < posz-20 or j > posz +20:
#				if sBodys[i][j] != null:
#					remove_child(sBodys[i][j])
#					sBodys[i][j].queue_free()	
#					sBodys[i][j] = null

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
	#var noise = OpenSimplexNoise.new()
	var noise = FastNoiseLite.new()
	randomize()
	noise.seed = randi()
	#noise.period = 130.0
	#noise.persistence = 0.8

	for x in range(worldsize):
		for z in range(worldsize):
			var y = noise.get_noise_2d(x,z)+1
			y = floor(y*50)-50
			setBlock_and_add_to_array(x,y,z)
			
			
