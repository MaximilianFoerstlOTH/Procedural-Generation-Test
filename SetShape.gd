extends StaticBody

onready var terrain = $TerrainGeneration
onready var collider = $CollisionShape

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collider.shape = terrain.multimesh.mesh.create_convex_shape()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
