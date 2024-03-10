extends CharacterBody3D

signal grabItem(player)
signal disappearItem()
signal addItemToInventory(item)

signal attemptToPlaceItem

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#  :=  symbol means I KNOW WHAT TYPE THIS VAR IS instead of eh its whatever
@onready var neck := $neck
@onready var camera := $neck/Camera3D

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
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
	move_and_slide()
	
	if Input.is_action_just_pressed("grab"):
		#print("grab")
		emit_signal("grabItem", self) #to pickup ray
	
	if Input.is_action_just_pressed("openInventory"):
		if $inventory/TextureRect.visible:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$inventory.setVisibility(!$inventory/TextureRect.visible)
	
	if Input.is_action_just_pressed("sprint"):
		SPEED *= 5.0
	
	if Input.is_action_just_released("sprint"):
		SPEED /= 5.0
	
	if Input.is_action_just_pressed("hotbarNext"):
		$hotbar.navigateAdd(1)
	
	if Input.is_action_just_pressed("hotbarPrevious"):
		$hotbar.navigateAdd(-1)
	
	if Input.is_action_just_pressed("placeItem"):
		emit_signal("attemptToPlaceItem")


func _on_collider_item_confirmed(item):
	#print("player")
	if !is_connected("disappearItem", Callable(item, "_on_player_disappear_item")):
		connect("disappearItem", Callable(item, "_on_player_disappear_item"))
	emit_signal("addItemToInventory", item)
	emit_signal("disappearItem")
