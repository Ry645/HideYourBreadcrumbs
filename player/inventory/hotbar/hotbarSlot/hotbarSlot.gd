extends Panel

@export var itemClass:Resource
var slotRef:Slot = null

@onready var textLabel = %RichTextLabel
@onready var rect = %TextureRect

func updateSelf(slot):
	slotRef = slot
	if slotRef.item == null:
		hideLabel()
		return
	
	textLabel.text = str(slotRef.item.number)
	rect.texture = slotRef.item.itemRes.image
	if slotRef.item.number <= 0:
		hideLabel()

func hideLabel():
	textLabel.text = ""
	rect.texture = null
