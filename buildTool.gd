extends RayCast3D

@export var pickupRootClass:PackedScene

func _on_hotbar_place_item(itemRes, mainNode):
	if is_colliding():
		#var newItemInWorld:Node3D = itemRes.itemClass.instantiate() # (WHY THE HELL IS THE ITEMCLASS DISAPPEARING = RESOLVED) because it has a recursion seizure and defaults to setting it as a null value
		#mainNode.add_child(newItemInWorld)
		#newItemInWorld.global_position = get_collision_point() # get collision point wasn't working since the root node was previously not 3d
		# make sure you first make the prototype of the node in the parent you want to use it in, and then save the branch as a scene
		# INFO
		
		var newItemInWorld:PickupRoot = pickupRootClass.instantiate()
		newItemInWorld.itemRes = itemRes
		mainNode.add_child(newItemInWorld)
		newItemInWorld.global_position = get_collision_point()
		
		#print(get_collision_point())
		#print("place")
