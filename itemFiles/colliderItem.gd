extends Node3D

class_name ColliderItem

var itemRoot:Node

func itemGrabbed() -> ItemResource:
	#print(parentItem)
	itemRoot.pickupRoot.disappear_item()
	if itemRoot.has_method("getItemRes"):
		return itemRoot.getItemRes()
	else:
		return itemRoot.pickupRoot.itemRes
	

func craftInto():
	itemRoot.craftInto()

func getBuildSnapGlobalLocation():
	if itemRoot.has_node("snapLocation"):
		return itemRoot.get_node("snapLocation").global_position
	else:
		#print("snap location not there")
		return false
