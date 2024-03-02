extends Panel


var itemClass = preload("res://item.tscn")
var slotRef:Slot = null

func updateSelf(slot):
	slotRef = slot
	$TextureRect.texture = slotRef.item.image
	$RichTextLabel.text = str(slotRef.item.number)

func hideLabel():
	$RichTextLabel.text = ""
	$TextureRect.texture = null
