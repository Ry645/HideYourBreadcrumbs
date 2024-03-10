# HEY
# LOOK HERE YOU LITTLE FUCKSHIT
# SCRIPT != NODE
# YOU ASSFACED IMBECILE

extends Node2D

# so this constructor is deriving directly from a script
# and if you go to the inventory.gd with this symbol ****************/
#class_name Item

# buuuuuuuuut it's still very useful for specifying types to make intellisense work in my favor
class_name Item

@onready var label = $RichTextLabel
@onready var rect = $TextureRect

var itemRes:Resource
var number:int = 1

signal itemUpdated

# Called when the node enters the scene tree for the first time.
func _ready():
	updateLabel()

func updateLabel():
	label.text = StringName(str(number))
	rect.texture = itemRes.image
	
	if number <= 0:
		visible = false
	else:
		visible = true

func updateExistence():
	if number <= 0:
		self.queue_free()

func update():
	updateExistence()
	updateLabel()
	emit_signal("itemUpdated")
	#print(self)

func setVars(resource:Resource, number1:int = 1):
	itemRes = resource
	number = number1

func setVarsFromItem(item:Item):
	itemRes = item.itemRes
