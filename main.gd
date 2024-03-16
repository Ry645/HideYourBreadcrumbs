extends Node3D

class_name Main

@onready var player:Player = %Player

# Called when the node enters the scene tree for the first time.
func _ready():
	setPlayerVarsOnReady()

func setPlayerVarsOnReady():
	player.main = self
