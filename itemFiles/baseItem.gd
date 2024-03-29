extends Node3D

class_name BaseItem

var pickupRoot:PickupRoot
@export var collider:Node3D

func _ready():
	collider.itemRoot = self

func craftInto():
	pickupRoot.craftInto()
	#TODO
	#make different type of crafting for each input so things aren't linear
	# ie press F for rope and also press I for Wool
