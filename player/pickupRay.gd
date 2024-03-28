# mask is SEARCHING for an object to collide with IN THAT LAYER
# layer is... well... in combination with mask

extends RayCast3D

signal returnItem(itemRes:ItemResource)

func _on_player_grab_item():
	# collider means the first object that collides with the raycast
	#print("pickup")
	var grabbedItemRes:ItemResource
	if get_collider():
		if get_collider().has_method("itemGrabbed"):
			grabbedItemRes = get_collider().itemGrabbed()
			emit_signal("returnItem", grabbedItemRes)
			#print("collide")
