extends RayCast3D

class_name InteractRay

signal itemFound(item:ItemResource)

func getItem():
	if get_collider():
		if get_collider().has_method("interact"):
			emit_signal("itemFound", get_collider().interact())
