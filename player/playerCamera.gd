extends Camera3D

class_name PlayerCamera

var exposureElapsedTime:float
var startExposure:float
var endExposure:float
var exposureEndTime:float

var isLerpingExposure:bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isLerpingExposure:
		exposureElapsedTime += delta
		var t = exposureElapsedTime/exposureEndTime
		attributes.exposure_multiplier = lerpf(startExposure, endExposure, t)
		
		if t >= 1:
			attributes.exposure_multiplier = endExposure
			isLerpingExposure = false

func interpolateToExposure(multiplier:float, time:float):
	isLerpingExposure = true
	startExposure = attributes.exposure_multiplier
	endExposure = multiplier
	exposureEndTime = time
	exposureElapsedTime = 0
