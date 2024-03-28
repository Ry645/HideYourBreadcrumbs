extends Node3D

class_name CarpetStrand

var pickupRoot:PickupRoot
@onready var collider = %Collider

func _ready():
	collider.itemRoot = self

func craftInto():
	pickupRoot.craftInto()
	#TODO
	#make different type of crafting for each input so things aren't linear
	# ie press F for rope and also press I for Wool
