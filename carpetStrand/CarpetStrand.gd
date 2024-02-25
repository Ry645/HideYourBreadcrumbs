extends Node3D

class_name CarpetStrand

@export var itemImage:CompressedTexture2D

func _on_player_disappear_item():
	queue_free()
	#print("poot")
