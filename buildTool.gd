extends RayCast3D

class_name BuildTool

@export var pickupRootClass:PackedScene
@export var itemsToExclude:Array[ItemResource]

var placeVector:Vector3

func _physics_process(_delta):
	placeVector = get_collision_point()
	checkSnap()

func snapPlacement(snapTo:Vector3):
	placeVector = snapTo

func _on_hotbar_place_item(itemRes, mainNode, ignoreRayChecks:bool = false):
	if !ignoreRayChecks:
		for item in itemsToExclude:
			if itemRes == item:
				return
	
	if ignoreRayChecks:
		placeItem(itemRes, mainNode)
		return
	if is_colliding():
		#var newItemInWorld:Node3D = itemRes.itemClass.instantiate() # (WHY THE HELL IS THE ITEMCLASS DISAPPEARING = RESOLVED) because it has a recursion seizure and defaults to setting it as a null value
		#mainNode.add_child(newItemInWorld)
		#newItemInWorld.global_position = get_collision_point() # get collision point wasn't working since the root node was previously not 3d
		# make sure you first make the prototype of the node in the parent you want to use it in, and then save the branch as a scene
		# INFO
		
		placeItem(itemRes, mainNode)
		
		#print(get_collision_point())
		#print("place")

func placeItem(itemRes, mainNode):
	var newItemInWorld:PickupRoot = pickupRootClass.instantiate()
	newItemInWorld.itemRes = itemRes
	mainNode.add_child(newItemInWorld)
	newItemInWorld.global_position = placeVector

# weird misalignment when snapping sometimes
# most noticable when placing rope using snapping
# RESOLVED

#bug caused by player movement
#seems to lag by a frame and placement isn't instant
#store the vector to fix
func checkSnap():
	#var a:Node3D
	#a.has_node("%snapLocation")
	if get_collider() && get_collider().has_method("getBuildSnapGlobalLocation"):
		var vect = get_collider().getBuildSnapGlobalLocation()
		if vect is Vector3:
			snapPlacement(vect)
		else:
			#print("fail in ", self)
			pass
