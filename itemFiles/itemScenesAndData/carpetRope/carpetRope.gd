extends Node3D

class_name CarpetRope

var pickupRoot
@export var static_body_3d:StaticBody3D

func _ready():
	static_body_3d.itemRoot = self

func craftInto():
	pickupRoot.craftInto()


func _on_area_3d_body_entered(body:Node3D):
	if body.has_method("climbToggle"):
		body.climbToggle(true)

func _on_area_3d_body_exited(body):
	if body.has_method("climbToggle"):
		body.climbToggle(false)

#glitch where while standing on rope and move against wall you bounce
#FIX
