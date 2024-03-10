extends Node2D


#@onready var inventory:Inventory = get_node("inventory")
@export var itemClass: Resource

@export var selectedStyle: Resource

@onready var hotbarInvSlots = get_parent().get_tree().get_nodes_in_group("hotbarInventorySlots")
@onready var hotbarSlots = $hotbarContainer.get_children()

var selectedSlotIndex:int = 0

func _ready():
	for i in range(hotbarInvSlots.size()):
		hotbarInvSlots[i].connect("updated", Callable(hotbarSlots[i], "updateSelf"))
		hotbarInvSlots[i].connect("childDisconnected", Callable(hotbarSlots[i], "hideLabel"))
	
	hotbarSlots[selectedSlotIndex].add_theme_stylebox_override("panel", selectedStyle)

func navigateAdd(number):
	var previous = selectedSlotIndex
	selectedSlotIndex = positiveModFunctionIStoleFromStackOverflow((selectedSlotIndex + number), hotbarSlots.size())
	updateSlotSelection(previous)
	#print(selectedSlotIndex)

func navigateSet(number):
	var previous = selectedSlotIndex
	selectedSlotIndex = positiveModFunctionIStoleFromStackOverflow(number, hotbarSlots.size())
	updateSlotSelection(previous)

#I'm a fuckin theif
func positiveModFunctionIStoleFromStackOverflow(number, mod):
	return (number % mod + mod) % mod
#ok fine credit where credit is due: https://stackoverflow.com/questions/14997165/fastest-way-to-get-a-positive-modulo-in-c-c

func updateSlotSelection(previousSlotIndex):
	hotbarSlots[previousSlotIndex].remove_theme_stylebox_override("panel")
	hotbarSlots[selectedSlotIndex].add_theme_stylebox_override("panel", selectedStyle)
