extends Node2D

@export var stringSegmentScene:PackedScene
@onready var string_holder = %stringHolder


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = string_holder
	for i in range(8):
		var segment = stringSegmentScene.instantiate()
		var pin:PinJoint2D = segment.get_node("PinJoint2D")
		pin.node_a = parent.get_path()
		pin.softness = 0.2
		segment.gravity_scale = 0
		parent.add_child(segment)
		
		parent = segment
