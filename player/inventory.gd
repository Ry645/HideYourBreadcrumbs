extends Node

# dear god fuck i hope this shitty spaghetti code doesn't come back to penetrate my ass later
# FIX

# let's gooooo i'm fixing it now

@onready var inventorySlots = $TextureRect/GridContainer
@onready var tooltipRoot:Tooltip = $TextureRect/tooltipRoot
var holdingItem:Item = null
var itemClass = preload("res://item.tscn")
var awaitingLeftClickReleaseForPlace:bool #needed for clicking and dragging for split items evenly
var awaitingRightClickReleaseForPlace:bool

var focusedSlot:Slot
var hoveredSlots:Array = []
var slotsAreActive:bool

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
			if holdingItem:
				holdingItem.update()
	
	if focusedSlot && !focusedSlot.mouseInSlot:
		hideTooltip(lastHoveredSlotForTooltip)

func _ready():
	for slot in inventorySlots.get_children():
		slot.connect("gui_input_new", Callable(self, "slotGuiInput")) # attaching signals
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
		
		#left click
		#pressed click
		#mouse holding item
		#occupied slot
		#not the same two items
		if event.button_index == MOUSE_BUTTON_LEFT && holdingItem != null && slot.item != null && slot.item.itemType != holdingItem.itemType: #swap items
			awaitingLeftClickReleaseForPlace = true
			if event.is_released() && awaitingLeftClickReleaseForPlace:
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
		elif event.button_index == MOUSE_BUTTON_LEFT && holdingItem != null: # add to item number
			awaitingLeftClickReleaseForPlace = true
			if event.is_released() && awaitingLeftClickReleaseForPlace:
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
		#mouse holding item
		if event.button_index == MOUSE_BUTTON_RIGHT && holdingItem != null: #place one into empty slot
			awaitingRightClickReleaseForPlace = true
			if event.is_released() && awaitingRightClickReleaseForPlace:
				awaitingRightClickReleaseForPlace = false
		
		#right click
		#pressed click
		#mouse not holding item
		#occupied slot
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed() && holdingItem == null && slot.item != null: # take half
			print("half")
			holdingItem = slot.pickHalfFromSlot()
			holdingItem.global_position = event.global_position





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
	for i in range(20):
		var itemObj:Item = itemClass.instantiate()
		itemObj.setVars("carpetStrand", load("res://carpetStrand/carpetStrandImage.png"))
		addItemToInventory(itemObj)
	for i in range(20):
		var itemObj:Item = itemClass.instantiate()
		itemObj.setVars("kimchi", load("res://jongga_kimchi.png"))
		addItemToInventory(itemObj)
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
		#print("hover")

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
		if distributedFirstItem: #need this to evenly distribute (ie:    5 5 5 5 = 20    ------>    4 4 4 4 4 = 20)
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
			slot.createOneIntoSlot(holdingItem)
		else: # dragging into filled slot with not same item
			hoveredSlots.remove_at(hoveredSlots.size() - 1)
			return
		holdingItem.updateLabel()




func showTooltip(slot:Slot):
	if !tooltipRoot.tooltipActive:
		slot.connect("mouseExitedForTooltip", Callable(self, "hideTooltip"))
		tooltipRoot.showTooltip(slot.item.itemType)
		lastHoveredSlotForTooltip = slot

func hideTooltip(slot:Slot):
	if tooltipRoot.tooltipActive:
		slot.disconnect("mouseExitedForTooltip", Callable(self, "hideTooltip"))
		tooltipRoot.hideTooltip()
