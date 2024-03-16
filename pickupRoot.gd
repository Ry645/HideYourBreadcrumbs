extends Node3D

class_name PickupRoot

@export var itemRes:itemResource

var itemNode

# Called when the node enters the scene tree for the first time.
func _ready():
	if itemRes != null:
		itemNode = itemRes.itemClass.instantiate()
		add_child(itemNode)
		itemNode.pickupRoot = self
	else:
		print("null item res in ", self)

func _on_player_disappear_item():
	queue_free()
	#print("poot")
