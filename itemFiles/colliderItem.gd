extends StaticBody3D

class_name ColliderItem

signal itemConfirmed(item)

var itemRoot:Node

func _on_pickupRay_itemGrabbed(player):
	#print(parentItem)
	if !is_connected("itemConfirmed", Callable(player, "_on_collider_item_confirmed")):
		connect("itemConfirmed", Callable(player, "_on_collider_item_confirmed"))
	emit_signal("itemConfirmed", itemRoot.pickupRoot)

func craftInto():
	itemRoot.craftInto()

func getBuildSnapGlobalLocation():
	if itemRoot.has_node("snapLocation"):
		return itemRoot.get_node("snapLocation").global_position
	else:
		#print("snap location not there")
		return false
