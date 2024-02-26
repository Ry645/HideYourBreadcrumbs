extends Node2D

class_name Tooltip

@onready var tooltipRoot = $"."
@onready var tooltip:RichTextLabel = $tooltipBackground/tooltip

var tooltipActive:bool

func showTooltip(text):
	if !tooltipActive:
		tooltipActive = true
		tooltipRoot.visible = true
		tooltip.text = text

func hideTooltip():
	if tooltipActive:
		tooltipActive = false
		tooltipRoot.visible = false
