extends Node2D


#@onready var inventory:Inventory = get_node("inventory")
var itemClass = preload("res://item.tscn")
@onready var hotbarInvSlots = get_parent().get_tree().get_nodes_in_group("hotbarInventorySlots")
@onready var hotbarSlots = $hotbarContainer.get_children()

func _ready():
	for i in range(hotbarInvSlots.size()):
		hotbarInvSlots[i].connect("updated", Callable(hotbarSlots[i], "updateSelf"))
		hotbarInvSlots[i].connect("childDisconnected", Callable(hotbarSlots[i], "hideLabel"))
