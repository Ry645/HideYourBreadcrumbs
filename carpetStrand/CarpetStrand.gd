extends Node3D

class_name CarpetStrand

var pickupRoot
@onready var collider = %Collider

func _ready():
	collider.itemRoot = self
