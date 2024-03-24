extends Panel

class_name Slot

@export var itemClass:Resource
var item:Item = null
var mouseInSlot: bool
var currentEvent

@onready var itemLocationNode = %itemLocation
@onready var inventoryParentNode = find_parent("inventory")

var canSignalMouseHover:bool = false
var sentHoverMessage:bool = false
signal mouseIsHovering(slot)

var sentHoverMessageForTooltip:bool = false
signal mouseIsHoveringForTooltip(slot)
signal mouseExitedForTooltip(slot)

signal updated(slot)
signal childDisconnected()

signal gui_input_new(event, slot)

# RESOLVED
# item == null doesn't account for if when you drag the item onto the same type, just when there's an item there in the slot
func _process(_delta):
	if canSignalMouseHover && mouseInSlot && !sentHoverMessage:  # && item == null
		# for click drag to distribute items
		sentHoverMessage = true
		emit_signal("mouseIsHovering", self)
	#if mouseInSlot && item:
		#emit_signal("mouseIsHoveringForTooltip", self)
	#if !mouseInSlot && item:
		#emit_signal("mouseExitedForTooltip", self)

# all of this reparenting of item needed to make it hover over mouse cursor when picked up
func pickFromSlot():
	disconnectChild(item)
	inventoryParentNode.add_child(item)
	item.update()
	item = null

func putIntoSlot(newItem):
	item = newItem
	item.position = Vector2(0,0)
	if inventoryParentNode.is_ancestor_of(item):
		inventoryParentNode.remove_child(item)
	connectChild(item)
	item.update()

func addIntoSlot(newItem):
	item = newItem
	item.position = Vector2(0,0)
	connectChild(item)
	item.update()

func addItemNumber(newItem):
	item.number += newItem.number
	item.update()
	newItem.queue_free()

func addItemByNumber(number):
	item.number += number
	item.update()

func putOneIntoSlot(newItem):
	item.number += 1
	newItem.number -= 1
	item.update()
	newItem.update()

func createOneIntoSlot(newItem:Item):
	item = itemClass.instantiate()
	item.setVarsFromItem(newItem)
	connectChild(item)
	newItem.number -= 1
	item.update()
	newItem.update()

func pickHalfFromSlot():
	var heldItem = itemClass.instantiate()
	
	heldItem.setVarsFromItem(item)
	heldItem.number = int(ceil(item.number/2.0))
	item.number = item.number-heldItem.number
	
	inventoryParentNode.add_child(heldItem)
	item.update()
	heldItem.update()
	return heldItem


func _on_gui_input(event):
	emit_signal("gui_input_new", event, self)

func _on_mouse_entered():
	mouseInSlot = true

func _on_mouse_exited():
	mouseInSlot = false

func setCanSignalMouseHover(can:bool):
	canSignalMouseHover = can

func reset():
	sentHoverMessage = false



func connectChild(theItem):
	itemLocationNode.add_child(theItem)
	theItem.connect("itemUpdated", Callable(self, "onItemUpdate"))

func disconnectChild(theItem):
	emit_signal("childDisconnected")
	itemLocationNode.remove_child(theItem)
	theItem.disconnect("itemUpdated", Callable(self, "onItemUpdate"))

func onItemUpdate():
	emit_signal("updated", self)
