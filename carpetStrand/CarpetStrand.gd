extends Node3D

class_name CarpetStrand

@export var itemResPath:String

var isPlaceable:bool = true

func _on_player_disappear_item():
	queue_free()
	#print("poot")
