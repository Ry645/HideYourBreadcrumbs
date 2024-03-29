extends BaseItem

class_name CarpetRope

@export var coiledRopeRes:ItemResource


func _on_area_3d_body_entered(body:Node3D):
	if body.has_method("climbToggle"):
		body.climbToggle(true)

func _on_area_3d_body_exited(body):
	if body.has_method("climbToggle"):
		body.climbToggle(false)

func getItemRes() -> ItemResource:
	return coiledRopeRes

#glitch where while standing on rope and move against wall you bounce
#FIX
