extends Area3D

@export var itemToGet:ItemResource

#implement later
#TODO
func getMinigame():
	pass

func getItem() -> ItemResource:
	return itemToGet

func interact() -> ItemResource:
	var item:ItemResource = getItem()
	queue_free()
	return item
