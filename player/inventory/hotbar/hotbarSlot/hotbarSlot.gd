extends Panel

@export var itemClass:Resource
var slotRef:Slot = null

@onready var textLabel = $itemLocation/RichTextLabel
@onready var rect = $itemLocation/TextureRect

func updateSelf(slot):
	slotRef = slot
	textLabel.text = str(slotRef.item.number)
	rect.texture = slotRef.item.itemRes.image
	if slotRef.item.number <= 0:
		hideLabel()

func hideLabel():
	textLabel.text = ""
	rect.texture = null
