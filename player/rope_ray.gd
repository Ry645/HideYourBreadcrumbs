extends RayCast3D

#make sure to set collide with areas to true in inspector
#INFO

signal latchFound(latch:RopeLatchPoint)

@export var ropeRes:ItemResource

func findLatch():
	if get_collider() is RopeLatchPoint:
		emit_signal("latchFound", get_collider())

func itemResourceIsRope(itemRes):
	print(itemRes)
	print(ropeRes)
	return itemRes == ropeRes
