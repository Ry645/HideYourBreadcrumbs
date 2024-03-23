class_name Hotbar

extends Node2D


#@onready var inventory:Inventory = get_node("inventory")
@export var itemClass: Resource

@export var selectedStyle: Resource

signal placeItem(itemRes, mainNode, ignoreRayRange)

@onready var player:Player
@onready var hotbarInvSlots
@onready var hotbarSlots = %hotbarContainer.get_children()

var selectedSlotIndex:int = 0

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

# and I could've just clamped it
# oh well
# INFO


func updateSlotSelection(previousSlotIndex):
	hotbarSlots[previousSlotIndex].remove_theme_stylebox_override("panel")
	hotbarSlots[selectedSlotIndex].add_theme_stylebox_override("panel", selectedStyle)


func _on_player_attempt_to_place_item(mainNode, ignoreRayRange:bool = false):
	if hotbarSlots[selectedSlotIndex].slotRef.item == null:
		return
	
	var itemRes:Resource = hotbarSlots[selectedSlotIndex].slotRef.item.itemRes
	if itemRes.isPlaceable:
		emit_signal("placeItem", itemRes, mainNode, ignoreRayRange)


func _initializeVarsOnReady(): #called by onready from player
	hotbarInvSlots = player.get_tree().get_nodes_in_group("hotbarInventorySlots")
	
	for i in range(hotbarInvSlots.size()):
		hotbarSlots[i].slotRef = hotbarInvSlots[i]
		hotbarInvSlots[i].connect("updated", Callable(hotbarSlots[i], "updateSelf"))
		hotbarInvSlots[i].connect("childDisconnected", Callable(hotbarSlots[i], "hideLabel"))
	
	hotbarSlots[selectedSlotIndex].add_theme_stylebox_override("panel", selectedStyle)
