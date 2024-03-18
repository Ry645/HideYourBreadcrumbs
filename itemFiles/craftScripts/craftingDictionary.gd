class_name CraftingDictionary

#@export var craftResources:Array[CraftResource]

#INFO
#so this is a static type for a class to access, not an object ======= static keyword
static var craftOptions = {}

#I can also just say that a key exists when setting a value and it will just appear out of thin air
#pretty cool

static func setCraftOptions(craftResources:Array[CraftResource]):
	for i in range(craftResources.size()):
		craftOptions[craftResources[i].baseItem] = craftResources[i].craftOptionsInOrder
