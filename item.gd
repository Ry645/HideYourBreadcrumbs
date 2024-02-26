# HEY
# LOOK HERE YOU LITTLE FUCKSHIT
# SCRIPT != NODE
# YOU ASSFACED IMBECILE

extends Node2D

# so this constructor is deriving directly from a script
# and if you go to the inventory.gd with this symbol ****************/
#class_name Item

# buuuuuuuuut it's still very useful for specifying types so intellisense works in my favor
class_name Item

@onready var label = $RichTextLabel
@onready var rect = $TextureRect
var itemType:StringName = "null"
var image:CompressedTexture2D = null
var number:int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	updateLabel()

func updateLabel():
	label.text = StringName(str(number))
	rect.texture = image

func updateExistence():
	if number <= 0:
		self.queue_free()

func update():
	updateExistence()
	updateLabel()
	#print(self)

func setVars(itemType1:StringName, image1:CompressedTexture2D, number1:int = 1):
	itemType = itemType1
	image = image1
	number = number1

func setVarsFromItem(item:Item):
	itemType = item.itemType
	image = item.image
