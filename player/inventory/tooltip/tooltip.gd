extends Node2D

class_name Tooltip

@onready var tooltip:RichTextLabel = %tooltip

var tooltipActive:bool

func showTooltip(text):
	if !tooltipActive:
		tooltipActive = true
		visible = true
		tooltip.text = text

func hideTooltip():
	if tooltipActive:
		tooltipActive = false
		visible = false
