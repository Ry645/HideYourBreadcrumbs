extends RayCast3D

class_name CraftingRay

func findItemToCraft():
	#var r = get_collider()
	#print(r)
	if get_collider() && get_collider().has_method("craftInto"):
		get_collider().craftInto()
