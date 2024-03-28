extends RayCast3D

#make sure to set collide with areas to true in inspector when making rays like this one
#INFO

signal latchFound(latch:RopeLatchPoint)

@export var pickupRootClass:PackedScene
@export var ropeRes:ItemResource

@export var thrownRopeRes:ItemResource

func findLatch():
	if get_collider() is RopeLatchPoint:
		emit_signal("latchFound", get_collider())

func itemResourceIsRope(itemRes):
	#print(itemRes)
	#print(ropeRes)
	return itemRes == ropeRes

func throwRope(item:Item, mainNode, latchPosition:Vector3):
	var newItemInWorld:PickupRoot = pickupRootClass.instantiate()
	newItemInWorld.itemRes = thrownRopeRes
	mainNode.add_child(newItemInWorld)
	newItemInWorld.global_position = latchPosition
	
	item.number -= 1
	item.update()
