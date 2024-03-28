extends Node3D

class_name PickupRoot

@export var itemRes:ItemResource

#make hashmap or dictionary maybe? Actually yes for input actions to get their index values to access the craft options array
#TODO

var itemNode:Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if itemRes != null:
		spawnItemChildFromItemRes()
	else:
		print("null itemResource in ", self)

func disappear_item():
	queue_free()
	#print("poot")

func craftInto(index:int = 0):
	if CraftingDictionary.craftOptions[itemRes] != null:
		if CraftingDictionary.craftOptions[itemRes].size() == 0:
			return
	
	itemRes = CraftingDictionary.craftOptions[itemRes][index]
	itemNode.queue_free()
	spawnItemChildFromItemRes()
	

func spawnItemChildFromItemRes():
	itemNode = itemRes.itemClass.instantiate()
	add_child(itemNode)
	itemNode.pickupRoot = self
