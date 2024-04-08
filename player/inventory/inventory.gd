extends Node

class_name Inventory

# dear god fuck i hope this shitty spaghetti code doesn't come back to penetrate my ass later
# FIX

# let's gooooo i'm fixing it now

@export var columnNumber:int = 9
@export var rowNumber:int = 4

@onready var inventorySlots = %GridContainer
@onready var tooltipRoot:Tooltip = %tooltipRoot
@onready var texture_rect = %TextureRect

var holdingItem:Item = null
@export var itemClass:Resource
var awaitingLeftClickReleaseForPlace:bool #needed for clicking and dragging for split items evenly
var awaitingRightClickReleaseForPlace:bool

@export var testItems:Array[ItemResource]
@export var testItemCounts:Array[int]
@export var canAddTestItems:bool = false

var focusedSlot:Slot
var hoveredSlots:Array = []
var slotsAreActive:bool

var lastHoveredSlotForTooltip #for comparison

var distributedItemsNumber:int
var distributedFirstItem:bool

signal setSlotAct(can)
signal resetSlots()

func _process(_delta):
	if awaitingLeftClickReleaseForPlace || awaitingRightClickReleaseForPlace: #when dragging items
		if !slotsAreActive:
			slotsAreActive = true
			emit_signal("setSlotAct", true)
	else:
		if slotsAreActive:
			emit_signal("resetSlots")
			emit_signal("setSlotAct", false)
			if holdingItem:
				holdingItem.update()
	
	if focusedSlot && !focusedSlot.mouseInSlot: # check if mouse outside focused slot to hide tooltip
		hideTooltip(lastHoveredSlotForTooltip)

func _ready():
	self.connect("resetSlots", Callable(self, "reset"))
	connectSlotSignals()
	if canAddTestItems:
		addTestItems()

func slotGuiInput(event, slot):
	#yes, I know that if I left click and right click on a single item at the same time, it deletes the item.
	#no, I don't care.
	#also, I know that if the player exits the inventory while holding an item the thing stays there floating on the cursor.
	#no, I don't care.
	#but anyways,
	# FIX
	
	focusedSlot = slot
	
	if slot.item != null:
		showTooltip(slot)
	if slot != lastHoveredSlotForTooltip:
		hideTooltip(lastHoveredSlotForTooltip)
	
	if event is InputEventMouseButton: #mouse click
		
		#left click
		#pressed click
		#mouse holding item
		#occupied slot
		#not the same two items
		if event.button_index == MOUSE_BUTTON_LEFT && holdingItem != null && slot.item != null && slot.item.itemRes != holdingItem.itemRes && !awaitingRightClickReleaseForPlace: #swap items
			awaitingLeftClickReleaseForPlace = true
			if event.is_released() && awaitingLeftClickReleaseForPlace:
				if hoveredSlots.size() <= 1:
					#print("swap")
					var tempItem = slot.item #need placeholder
					slot.pickFromSlot() #grab item
					tempItem.position = event.position + texture_rect.position + inventorySlots.position + slot.position
					slot.putIntoSlot(holdingItem) # slap into slot
					holdingItem = tempItem #complete
				awaitingLeftClickReleaseForPlace = false
		
		#left click
		#pressed click
		#mouse holding item
		elif event.button_index == MOUSE_BUTTON_LEFT && holdingItem != null && !awaitingRightClickReleaseForPlace: # add to item number
			awaitingLeftClickReleaseForPlace = true
			if event.is_released() && awaitingLeftClickReleaseForPlace:
				awaitingLeftClickReleaseForPlace = false
		
		#left click
		#pressed click
		#mouse not holding item
		#occupied slot
		elif event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && holdingItem == null && slot.item != null && !awaitingRightClickReleaseForPlace: #take item from slot
			holdingItem = slot.item
			slot.pickFromSlot()
			holdingItem.position = event.position + texture_rect.position + inventorySlots.position + slot.position
		
		
		
		
		
		#right click
		#mouse holding item
		elif event.button_index == MOUSE_BUTTON_RIGHT && holdingItem != null && !awaitingLeftClickReleaseForPlace: #place one into empty slot
			awaitingRightClickReleaseForPlace = true
			if event.is_released() && awaitingRightClickReleaseForPlace:
				awaitingRightClickReleaseForPlace = false
		
		#right click
		#pressed click
		#mouse not holding item
		#occupied slot
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed() && holdingItem == null && slot.item != null && !awaitingLeftClickReleaseForPlace: # take half
			#print("half")
			holdingItem = slot.pickHalfFromSlot()
			holdingItem.position = event.position + texture_rect.position + inventorySlots.position + slot.position





func _input(event):
	if event is InputEventMouseMotion: # move item and tooltip
		if holdingItem != null:
			holdingItem.position = event.position
		tooltipRoot.position = event.position - texture_rect.position #HOW DA FUQ


# weird bug that cropped up that prevents me from taking half a stack from a slot
# maybe caused by my itemUpdate shenanigans
# BUG
func addItemToInventory(item:Item):
	var minHotbarIndex:int = (rowNumber-1) * columnNumber
	var maxHotbarIndex:int = inventorySlots.get_children().size()
	#all of this gets the hotbar row first
	
	
	# maybe fix this up into a for loop for clarity
	# TODO
	var itemWasAdded:bool = searchRangeForStacksAndAddItem(minHotbarIndex, maxHotbarIndex, item)
	if itemWasAdded:
		return
		
	itemWasAdded = searchRangeForStacksAndAddItem(0, minHotbarIndex, item)
	if itemWasAdded:
		return
		
	itemWasAdded = searchRangeForEmptySlotsAndAddItem(minHotbarIndex, maxHotbarIndex, item)
	if itemWasAdded:
		return
		
	itemWasAdded = searchRangeForEmptySlotsAndAddItem(0, minHotbarIndex, item)
	
	##this gets the rest of the rows
	#searchRangeToAddItem(0, minHotbarIndex, item)
	
	#for slot in inventorySlots.get_children():
		#if !slot.item: #slot has no item
			#slot.addIntoSlot(item)
			#break
		#elif slot.item.itemRes == item.itemRes:
			#slot.addItemNumber(item)
			#break

func searchRangeForStacksAndAddItem(minIndex:int, maxIndex:int, item:Item) -> bool:
	for i in range(minIndex, maxIndex):
		var slot:Slot = inventorySlots.get_children()[i]
		
		if slot.item != null && slot.item.itemRes == item.itemRes:
			slot.addItemNumber(item)
			return true
	
	return false

func searchRangeForEmptySlotsAndAddItem(minIndex:int, maxIndex:int, item:Item) -> bool:
	for i in range(minIndex, maxIndex):
		var slot:Slot = inventorySlots.get_children()[i]
		
		if !slot.item: #slot has no item
			slot.addIntoSlot(item)
			return true
	
	return false


#previous logic
#also didn't prioritize stacks
#func searchRangeToAddItem(minIndex:int, maxIndex:int, item:Item) -> bool:
	#for i in range(minIndex, maxIndex):
		#var slot:Slot = inventorySlots.get_children()[i]
		#
		#if slot.item != null && item != null && slot.item.itemRes == item.itemRes:
			#slot.addItemNumber(item)
			#return true
	#
	#for i in range(minIndex, maxIndex):
		#var slot:Slot = inventorySlots.get_children()[i]
		#
		#if !slot.item: #slot has no item
			#slot.addIntoSlot(item)
			#return true
	#
	#return false
	#
	##previous logic
	##didn't prioritize stacks
	##for i in range(minIndex, maxIndex):
		##var slot:Slot = inventorySlots.get_children()[i]
		##
		##if !slot.item: #slot has no item
			##slot.addIntoSlot(item)
			##itemWasAdded = true
			##break
		##elif slot.item.itemRes == item.itemRes:
			##slot.addItemNumber(item)
			##itemWasAdded = true
			##break


func _on_player_add_item_to_inventory(item):
	#SceneTree
	#addItemToInventory(Item.new(item.get_groups()[0])) #when you make this instance of a class, you're using the script, not the scene blueprint
	# that's why it doesn't work like the rest of the item nodes   ****************/
	
	var itemObj = itemClass.instantiate()
	
	if item is PickupRoot:
		itemObj.setVars(item.itemRes)
	elif item is ItemResource:
		itemObj.setVars(item)
		
	#itemObj.itemType = item.get_meta("itemType") #previous set
	#print(item.itemRes)
	addItemToInventory(itemObj) #this way is better and won't lead to anymore fuckups
	print("added")



func setVisibility(isVisibile):
	#ok so that's how it works
	texture_rect.visible = isVisibile


func addTestItems():
	while testItems.size() > testItemCounts.size():
		testItemCounts.append(20)
	for i in range(testItems.size()):
		for j in range(testItemCounts[i]):
			var itemObj:Item = itemClass.instantiate()
			itemObj.setVars(testItems[i])
			addItemToInventory(itemObj)

func addToHoveredSlots(slot): #linked to signal to add slots when slots are hovered over
	var unique = true
	if hoveredSlots:
		for newSlot in hoveredSlots:
			if newSlot == slot:
				unique = false
				break
	if unique:
		hoveredSlots.append(slot)
		#print("hover")

func distributeItems(slot:Slot): #left click drag items
	if awaitingLeftClickReleaseForPlace:
		if !distributedFirstItem:
			distributedItemsNumber = holdingItem.number
		
		@warning_ignore("integer_division")
		var temp = int(distributedItemsNumber/hoveredSlots.size())
		if temp <= 0:
			return
		
		#print(slot.item)
		if slot.item != null && holdingItem.itemRes && slot.item.itemRes == holdingItem.itemRes: # dragging into slot with same item
			@warning_ignore("integer_division")
			slot.addItemByNumber(int(distributedItemsNumber/hoveredSlots.size()))
		
		elif !slot.item: # dragging into empty slot
			var itemObj = itemClass.instantiate()
			itemObj.setVars(holdingItem.itemRes)
			@warning_ignore("integer_division")
			itemObj.number = int(distributedItemsNumber/hoveredSlots.size())
			#print(hoveredSlots.size())
			slot.putIntoSlot(itemObj)
		else: # dragging into filled slot with not same item
			hoveredSlots.remove_at(hoveredSlots.size() - 1)
			return
		if distributedFirstItem: #need this to evenly distribute (ie:    5 5 5 5 = 20    ------>    4 4 4 4 4 = 20)
			var i = 0
			for slotObj in hoveredSlots:
				@warning_ignore("integer_division")
				slotObj.item.number = slotObj.item.number - int(distributedItemsNumber/(hoveredSlots.size() - 1)) + int(distributedItemsNumber/hoveredSlots.size())
				slotObj.item.update()
				i += 1
				if i == hoveredSlots.size() - 1:
					break
		@warning_ignore("integer_division")
		holdingItem.number = distributedItemsNumber - int(distributedItemsNumber/hoveredSlots.size()) * hoveredSlots.size()
		holdingItem.updateLabel()
		distributedFirstItem = true

func distributeSingleItems(slot:Slot): # right click drag items
	if awaitingRightClickReleaseForPlace:
		if holdingItem && holdingItem.number <= 0:
			return
		
		if slot.item != null && holdingItem.itemRes && slot.item.itemRes == holdingItem.itemRes: # dragging into slot with same item
			slot.putOneIntoSlot(holdingItem)
		elif slot.item == null: # dragging into empty slot
			slot.createOneIntoSlot(holdingItem)
		else: # dragging into filled slot with not same item
			hoveredSlots.remove_at(hoveredSlots.size() - 1)
			return
		holdingItem.updateLabel()




func showTooltip(slot:Slot):
	if !tooltipRoot.tooltipActive:
		slot.connect("mouseExitedForTooltip", Callable(self, "hideTooltip"))
		tooltipRoot.showTooltip(slot.item.itemRes.itemType)
		lastHoveredSlotForTooltip = slot

func hideTooltip(slot:Slot):
	if tooltipRoot.tooltipActive:
		slot.disconnect("mouseExitedForTooltip", Callable(self, "hideTooltip"))
		tooltipRoot.hideTooltip()



func connectSlotSignals():
	for slot in inventorySlots.get_children():
		slot.connect("gui_input_new", Callable(self, "slotGuiInput")) # attaching signals
		self.connect("setSlotAct", Callable(slot, "setCanSignalMouseHover"))
		slot.connect("mouseIsHovering", Callable(self, "addToHoveredSlots"))
		slot.connect("mouseIsHovering", Callable(self, "distributeItems"))
		slot.connect("mouseIsHovering", Callable(self, "distributeSingleItems"))
		self.connect("resetSlots", Callable(slot, "reset"))
		#slot.connect("mouseIsHoveringForTooltip", Callable(self, "showTooltip"))

func reset(): # reset drag state
	slotsAreActive = false
	hoveredSlots = []
	distributedFirstItem = false
	distributedItemsNumber = 0


func am_i_visible() -> bool:
	return texture_rect.visible
