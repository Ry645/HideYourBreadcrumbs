extends StaticBody3D

signal itemConfirmed(item)

@export var parentItem:Node3D

func _on_pickupRay_itemGrabbed(player):
	#print(parentItem)
	if !is_connected("itemConfirmed", Callable(player, "_on_collider_item_confirmed")):
		connect("itemConfirmed", Callable(player, "_on_collider_item_confirmed"))
	emit_signal("itemConfirmed", parentItem)
