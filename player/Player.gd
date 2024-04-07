class_name Player

#default starting pos:
#x: -180
#y: 3
#z: 156

extends CharacterBody3D

signal grabItem()
signal disappearItem()
signal addItemToInventory(item)

signal attemptToPlaceItem(mainNode)

@export var SPEED:float = 5.0
@export var JUMP_VELOCITY:float = 4.5
@export var CLIMB_VELOCITY:float = 4.5

@export var canFly:bool = false
@export var gravityMultiplier:float = 1.0

@export var gloomTimeLimit:float = 60

enum MovementState{
	NORMAL,
	CLIMBING
}

var currentMovementState = MovementState.NORMAL
var surfacesClimbing:int = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#  :=  symbol means I KNOW WHAT TYPE THIS VAR IS instead of eh its whatever
@onready var neck := %neck
@onready var camera:Camera3D = %Camera3D
@onready var inventory:Inventory = %inventory
@onready var hotbar:Hotbar = %hotbar
@onready var crafting_ray:CraftingRay = %craftingRay
@onready var rope_ray = %ropeRay
@onready var build_tool:BuildTool = %buildTool
@onready var interact_ray:InteractRay = %interactRay
@onready var gloom_timer:Timer = %gloomTimer

var main

func _ready():
	hotbar.player = self
	hotbar._initializeVarsOnReady()

func _unhandled_input(event):
	# if not tabbed out (ie playing game)
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# if tabbed out (ie alt tab but in this case esc)  AND IT DOES DISABLE CAMERA MOVEMENT LATER IN THE CODE
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: # RIGHT HERE
		if event is InputEventMouseMotion:
			#relative is new mouse pos compared to old mouse pos
			#negative sign used for making feel more natural
			#also rotate_y means rotating along the y-axis
			#small number multiply b/c radians
			neck.rotate_y(-event.relative.x * 0.00125)
			camera.rotate_x(-event.relative.y * 0.00125)
			#neck separate from pivot point to account for moving forward and right without flying into the stratosphere
	
	camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta * gravityMultiplier

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() || currentMovementState == MovementState.CLIMBING || canFly:
			velocity.y = JUMP_VELOCITY
			
		currentMovementState = MovementState.NORMAL

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	# vector3(left/right, up/down but unused, forward/backward)
	# basis = orientation or perspective direction
	var direction = (neck.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() # So earlier i used neck.transform.basis, and while it sounded right, it was actually getting the RELATIVE direction of the neck, which is always 0.
	#Instead I should use neck.global_basis to get the true global direction.
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		#used to stop player
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if currentMovementState == MovementState.CLIMBING:
		velocity = Vector3.ZERO
		velocity.y = CLIMB_VELOCITY * Input.get_axis("down", "up")
		
		#print("climb")
		
	move_and_slide()
	
	#var a = get_last_slide_collision()
	#if Input.is_action_just_pressed("sprint"):
		#print(a)
		
	#the way this works is that it gets the collision you last slid on
	#but don't do that
	#use area3d instead
	#INFO
	
	inputProcess()
	





func inputProcess(): # to be called in physics process
	
	if Input.is_action_just_pressed("grab"):
		#print("grab")
		emit_signal("grabItem") #to pickup ray
	
	if Input.is_action_just_pressed("openInventory"):
		if inventory.am_i_visible():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		inventory.setVisibility(!inventory.am_i_visible())
	
	if Input.is_action_just_pressed("sprint"):
		SPEED *= 5.0
	
	if Input.is_action_just_released("sprint"):
		SPEED /= 5.0
	
	if Input.is_action_just_pressed("hotbarNext"):
		hotbar.navigateAdd(1)
	
	if Input.is_action_just_pressed("hotbarPrevious"):
		hotbar.navigateAdd(-1)
	
	if Input.is_action_just_pressed("placeItem"):
		emit_signal("attemptToPlaceItem", main)
	
	if Input.is_action_just_pressed("craft0"):
		crafting_ray.findItemToCraft()
	
	if Input.is_action_just_pressed("ropeThrow"):
		rope_ray.findLatch()
	
	if Input.is_action_just_pressed("interact"):
		interact_ray.getItem()


func climbToggle(climb:bool):
	if climb:
		surfacesClimbing += 1
	else:
		surfacesClimbing -= 1
	
	if surfacesClimbing > 0:
		currentMovementState = MovementState.CLIMBING
	elif surfacesClimbing == 0:
		currentMovementState = MovementState.NORMAL
	else:
		surfacesClimbing = 0
		currentMovementState = MovementState.NORMAL
		print("surfacesClimbing went below 0")
	
	#print(surfacesClimbing)


#func _on_collider_item_confirmed(item):
	##print("player")
	#if !is_connected("disappearItem", Callable(item, "_on_player_disappear_item")):
		#connect("disappearItem", Callable(item, "_on_player_disappear_item"))
	#emit_signal("addItemToInventory", item)
	#emit_signal("disappearItem")

func _on_rope_ray_latch_found(latch):
	if hotbar.hotbarSlots[hotbar.selectedSlotIndex].slotRef.item != null:
		var selectedItem:Item = hotbar.hotbarSlots[hotbar.selectedSlotIndex].slotRef.item
		if rope_ray.itemResourceIsRope(selectedItem.itemRes):
			rope_ray.throwRope(selectedItem, main, latch.global_position)


func _on_interact_ray_item_found(item:ItemResource):
	emit_signal("addItemToInventory", item)

func _on_pickup_ray_return_item(itemRes:ItemResource):
	emit_signal("addItemToInventory", itemRes)

func gloomEntered(gloomArea:GloomArea):
	camera.interpolateToExposure(gloomArea.alteredCameraExposure, gloomArea.exposureDarkenTime)
	gloom_timer.start(gloomTimeLimit)

func gloomExited(gloomArea:GloomArea):
	camera.interpolateToExposure(gloomArea.defaultCameraExposure, gloomArea.exposureRecoverTime)
	gloom_timer.stop()

func _on_gloom_timer_timeout():
	print("u ded")
	#TODO
	#create game failstate
