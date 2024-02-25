extends Node

# dear god fuck i hope this shitty spaghetti code doesn't come back to penetrate my ass later
# FIX

#const SlotClass = preload("res://slot.gd")

@onready var inventorySlots = $TextureRect/GridContainer
@onready var tooltipRoot = $TextureRect/tooltipRoot
@onready var tooltip:RichTextLabel = $TextureRect/tooltipRoot/tooltipBackground/tooltip
var holdingItem = null
var itemClass = preload("res://item.tscn")
var awaitingLeftClickReleaseForPlace:bool #needed for clicking and dragging for split items evenly
var awaitingRightClickReleaseForPlace:bool

var focusedSlot
var hoveredSlots:Array = []
var slotsAreActive:bool

var tooltipActive:bool
var lastHoveredSlotForTooltip #for comparison

var distributedItemsNumber:int
var distributedFirstItem:bool

signal setSlotAct(can)
signal resetSlots()

func _process(_delta):
	if awaitingLeftClickReleaseForPlace || awaitingRightClickReleaseForPlace:
		if !slotsAreActive:
			slotsAreActive = true
			emit_signal("setSlotAct", true)
	else:
		if slotsAreActive:
			slotsAreActive = false
			hoveredSlots = []
			distributedFirstItem = false
			distributedItemsNumber = 0
			emit_signal("resetSlots")
			emit_signal("setSlotAct", false)
			holdingItem.update()

func _ready():
	for slot in inventorySlots.get_children():
		slot.connect("gui_input_new", Callable(self, "slotGuiInput"))
		self.connect("setSlotAct", Callable(slot, "setCanSignalMouseHover"))
		slot.connect("mouseIsHovering", Callable(self, "addToHoveredSlots"))
		slot.connect("mouseIsHovering", Callable(self, "distributeItems"))
		slot.connect("mouseIsHovering", Callable(self, "distributeSingleItems"))
		self.connect("resetSlots", Callable(slot, "reset"))
		#slot.connect("mouseIsHoveringForTooltip", Callable(self, "showTooltip"))
	
	addTestItems()

func slotGuiInput(event, slot):
	#yes, I know that if I left click and right click on a single item at the same time, it deletes the item.
	#no, I don't care.
	#but anyways,
	# FIX
	
	focusedSlot = slot
	
	if slot.item:
		showTooltip(slot)
	if slot != lastHoveredSlotForTooltip:
		hideTooltip(lastHoveredSlotForTooltip)
	
	if event is InputEventMouseButton: #mouse click
		
		#HEY NO TOUCHY
		
		#left click
		#pressed click
		#mouse holding item
		#empty slot
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && holdingItem != null && !slot.item: # ready
			awaitingLeftClickReleaseForPlace = true
		elif event.button_index == MOUSE_BUTTON_LEFT && event.is_released() && holdingItem != null && !slot.item && awaitingLeftClickReleaseForPlace: # put item into slot
			#slot.putIntoSlot(holdingItem) #slap item into empty slot
			#holdingItem = null #not holding item
			awaitingLeftClickReleaseForPlace = false
		
		#left click
		#pressed click
		#mouse holding item
		#occupied slot
		#not the same two items
		elif event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && holdingItem != null && slot.item != null && slot.item.itemType != holdingItem.itemType: #swap items
			awaitingLeftClickReleaseForPlace = true
		elif event.button_index == MOUSE_BUTTON_LEFT && event.is_released() && holdingItem != null && slot.item != null && slot.item.itemType != holdingItem.itemType && awaitingLeftClickReleaseForPlace:
			if hoveredSlots.size() <= 1:
				#print("swap")
				var tempItem = slot.item #need placeholder
				slot.pickFromSlot() #grab item
				tempItem.global_position = event.global_position #snap to cursor
				slot.putIntoSlot(holdingItem) # slap into slot
				holdingItem = tempItem #complete
			awaitingLeftClickReleaseForPlace = false
		
		#left click
		#pressed click
		#mouse holding item
		#occupied slot
		#same two items
		elif event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && holdingItem != null && slot.item != null && slot.item.itemType == holdingItem.itemType: # add to item number
			awaitingLeftClickReleaseForPlace = true
		elif event.button_index == MOUSE_BUTTON_LEFT && event.is_released() && holdingItem != null && slot.item != null && slot.item.itemType == holdingItem.itemType && awaitingLeftClickReleaseForPlace:
			#slot.addItemNumber(holdingItem)
			#holdingItem = null
			awaitingLeftClickReleaseForPlace = false
		
		#left click
		#pressed click
		#mouse not holding item
		#occupied slot
		elif event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && holdingItem == null && slot.item != null: #take item from slot
			holdingItem = slot.item
			slot.pickFromSlot()
			holdingItem.global_position = event.global_position
		
		
		
		#right click
		#pressed click
		#mouse holding item
		#empty slot
		if event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed() && holdingItem != null && slot.item == null: #place one into empty slot
			awaitingRightClickReleaseForPlace = true
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.is_released() && holdingItem != null && slot.item == null && awaitingRightClickReleaseForPlace:
			#slot.createOneIntoSlot(holdingItem)
			awaitingRightClickReleaseForPlace = false
		
		#right click
		#pressed click
		#mouse holding item
		#occupied slot
		#same two items
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed() && holdingItem != null && slot.item != null && slot.item.itemType == holdingItem.itemType: #add one to item in slot
			awaitingRightClickReleaseForPlace = true
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.is_released() && holdingItem != null && slot.item != null && slot.item.itemType == holdingItem.itemType && awaitingRightClickReleaseForPlace:
			#slot.putOneIntoSlot(holdingItem)
			awaitingRightClickReleaseForPlace = false
		
		#right click
		#pressed click
		#mouse not holding item
		#occupied slot
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed() && holdingItem == null && slot.item != null: # take half
			holdingItem = slot.pickHalfFromSlot()
			holdingItem.global_position = event.global_position
		
		
		
		#previous logic below for the stuff above
		#stupid if nesting
		
		#if event.button_index == MOUSE_BUTTON_LEFT: #left click
			#
			#if holdingItem != null: #mouse holding item
				#
				#if slot.item == null: # empty slot ********************************************************
					#slot.putIntoSlot(holdingItem) #slap item into empty slot
					#holdingItem = null #not holding item
					#
				#else: #occupied slot
					#
					#if slot.item.itemType != holdingItem.itemType: # not the same two items = switch item ********************************************************
						##print("swap")
						#var tempItem = slot.item #need placeholder
						#slot.pickFromSlot() #grab item
						#tempItem.global_position = event.global_position #snap to cursor
						#slot.putIntoSlot(holdingItem) # slap into slot
						#holdingItem = tempItem #complete
						#
					#else: #are the same item = add to item number ********************************************************
						#slot.addItemNumber(holdingItem)
						#holdingItem = null
						#
			#elif slot.item: #mouse not holding item and there is slot item ********************************************************
				#holdingItem = slot.item
				#slot.pickFromSlot()
				#holdingItem.global_position = event.global_position
		#
		#
		#if event.button_index == MOUSE_BUTTON_RIGHT && event.is_released(): #right click
			#
			#if holdingItem != null: #mouse holding item
				#
				#if !slot.item: # empty slot ********************************************************
					#slot.createOneIntoSlot(holdingItem)
					#
				#else: #occupied slot
					#
					#if slot.item.itemType == holdingItem.itemType: # same two items = add one ********************************************************
						#slot.putOneIntoSlot(holdingItem)
						#
			#elif slot.item: #mouse not holding item and item in slot ********************************************************
				#holdingItem = slot.pickHalfFromSlot()
				#holdingItem.global_position = event.global_position

func _input(event):
	if event is InputEventMouseMotion:
		if holdingItem != null:
			holdingItem.global_position = event.global_position
		tooltipRoot.global_position = event.global_position



func addItemToInventory(item):
	for slot in inventorySlots.get_children():
		if !slot.item: #slot has no item
			slot.addIntoSlot(item)
			break
		elif slot.item.itemType == item.itemType:
			slot.addItemNumber(item)
			break


func _on_player_add_item_to_inventory(item):
	#SceneTree
	#addItemToInventory(Item.new(item.get_groups()[0])) #when you make this instance of a class, you're using the script, not the scene blueprint
	# that's why it doesn't work like the rest of the item nodes   ****************/
	
	var itemObj = itemClass.instantiate()
	#itemObj.itemType = item.get_meta("itemType") #previous set
	itemObj.setVars(item.get_meta("itemType"), item.itemImage)
	addItemToInventory(itemObj) #this way is better and won't lead to anymore fuckups
	print("added")



func setVisibility(isVisibile):
	#ok so that's how it works
	$TextureRect.visible = isVisibile


func addTestItems():
	#for i in range(40):
		#var itemObj = itemClass.instantiate()
		#itemObj.itemType = "a"
		#addItemToInventory(itemObj)
	#for i in range(10):
		#var itemObj = itemClass.instantiate()
		#itemObj.itemType = "b"
		#addItemToInventory(itemObj)
		pass

func addToHoveredSlots(slot): #linked to signal to add slots when slots are hovered over
	var unique = true
	if hoveredSlots:
		for newSlot in hoveredSlots:
			if newSlot == slot:
				unique = false
				break
	if unique:
		hoveredSlots.append(slot)
		print("hover")

func distributeItems(slot:Slot): #left click drag items
	if awaitingLeftClickReleaseForPlace:
		if !distributedFirstItem:
			distributedItemsNumber = holdingItem.number
		
		if int(distributedItemsNumber/hoveredSlots.size()) <= 0:
			return
		
		if slot.item && holdingItem.itemType && slot.item.itemType == holdingItem.itemType: # dragging into slot with same item
			slot.addItemByNumber(int(distributedItemsNumber/hoveredSlots.size()))
			
		elif !slot.item: # dragging into empty slot
			var itemObj = itemClass.instantiate()
			itemObj.setVars(holdingItem.itemType, holdingItem.image)
			itemObj.number = int(distributedItemsNumber/hoveredSlots.size())
			#print(hoveredSlots.size())
			slot.putIntoSlot(itemObj)
		else: # dragging into filled slot with not same item
			hoveredSlots.remove_at(hoveredSlots.size() - 1)
			return
		if distributedFirstItem:
			var i = 0
			for slotObj in hoveredSlots:
				slotObj.item.number = slotObj.item.number - int(distributedItemsNumber/(hoveredSlots.size() - 1)) + int(distributedItemsNumber/hoveredSlots.size())
				slotObj.item.update()
				i += 1
				if i == hoveredSlots.size() - 1:
					break
		holdingItem.number = distributedItemsNumber - int(distributedItemsNumber/hoveredSlots.size()) * hoveredSlots.size()
		holdingItem.updateLabel()
		distributedFirstItem = true

func distributeSingleItems(slot:Slot): # right click drag items
	if awaitingRightClickReleaseForPlace:
		if holdingItem.number <= 0:
			return
		
		if slot.item && holdingItem.itemType && slot.item.itemType == holdingItem.itemType: # dragging into slot with same item
			slot.putOneIntoSlot(holdingItem)
		elif !slot.item: # dragging into empty slot
			var itemObj:Item = itemClass.instantiate()
			#itemObj.itemType = holdingItem.itemType #earlier set
			itemObj.setVars(holdingItem.itemType, holdingItem.image)
			slot.putIntoSlot(itemObj)
		else: # dragging into filled slot with not same item
			hoveredSlots.remove_at(hoveredSlots.size() - 1)
			return
		holdingItem.number -= 1
		holdingItem.updateLabel()




func showTooltip(slot:Slot):
	if !tooltipActive:
		slot.connect("mouseExitedForTooltip", Callable(self, "hideTooltip"))
		tooltipActive = true
		tooltipRoot.visible = true
		tooltip.text = slot.item.itemType
		lastHoveredSlotForTooltip = slot

func hideTooltip(slot:Slot):
	if tooltipActive:
		slot.disconnect("mouseExitedForTooltip", Callable(self, "hideTooltip"))
		tooltipActive = false
		tooltipRoot.visible = false
