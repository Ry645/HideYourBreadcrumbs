extends Area3D

class_name GloomArea


@onready var collision_shape_3d:CollisionShape3D = %CollisionShape3D
@onready var fog_volume = %FogVolume

var defaultCameraExposure:float = 1
var alteredCameraExposure:float = 0
var exposureDarkenTime:float = 0.1 #in seconds
var exposureRecoverTime:float = 1 #in seconds

func _ready():
	fog_volume.size = collision_shape_3d.shape.size


func _on_body_entered(body):
	if body.has_method("gloomEntered"):
		body.gloomEntered(self)


func _on_body_exited(body):
	if body.has_method("gloomExited"):
		body.gloomExited(self)
