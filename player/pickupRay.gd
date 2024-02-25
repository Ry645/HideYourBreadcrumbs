# mask is SEARCHING for an object to collide with IN THAT LAYER
# layer is... well... in combination with mask

extends RayCast3D

signal itemGrabbed(player)


func _on_player_grab_item(player):
	# collider means the first object that collides with the raycast
	#print("pickup")
	if get_collider():
		#print("collide")
		if !is_connected("itemGrabbed", Callable(get_collider(), "_on_pickupRay_itemGrabbed")):
			connect("itemGrabbed", Callable(get_collider(), "_on_pickupRay_itemGrabbed"))
			emit_signal("itemGrabbed", player) #to item collision
