extends Area3D

@onready var collision_shape_3d:CollisionShape3D = %CollisionShape3D
@onready var fog_volume = %FogVolume


# Called when the node enters the scene tree for the first time.
func _ready():
	#needed to get global position
	#print($"../room3/dresser2/gloomBoxTransform".global_position)
	fog_volume.size = collision_shape_3d.shape.size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
