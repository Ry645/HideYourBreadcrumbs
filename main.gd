extends Node3D

class_name Main

@onready var player:Player = %Player
@export var craftResources:AllCraftResources

# Called when the node enters the scene tree for the first time.
func _ready():
	setPlayerVarsOnReady()
	setup()

func setPlayerVarsOnReady():
	player.main = self
func setup():
	CraftingDictionary.setCraftOptions(craftResources.array)
	#print(CraftingDictionary.craftOptions)
