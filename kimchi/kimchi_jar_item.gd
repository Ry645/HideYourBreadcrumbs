extends Node3D

class_name KimchiJar

var pickupRoot
@onready var static_body_3d = %StaticBody3D

func _ready():
	static_body_3d.itemRoot = self
