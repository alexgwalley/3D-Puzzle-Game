extends Spatial

#Input
var move_dif = 0.5
var move_snapiness = 8
var can_move = true
var desired = transform.origin

var can_move_input_pos = true
onready var input_pos = get_viewport().size/2
onready var desired_input_pos = get_viewport().size/2
var input_pos_move_dif = 8
var input_pos_move_snapiness = 10
onready var circle_size = get_parent().get_node("Mouse/TextureRect").rect_size*get_parent().get_node("Mouse/TextureRect").rect_scale
onready var input_pos_link = get_parent().get_node("Mouse")

# camera movement
var cameraBorderWidth = 100

# grid
onready var gridSize = 2
var prevID = Vector3(0, 0, 0)

# selection and moving
var selected = null

# placing blocks
var gateMode = 0
onready var OR_Gate = preload("res://Scenes/GATE_Scenes/OR_Gate.tscn")
onready var AND_Gate = preload("res://Scenes/GATE_Scenes/AND_Gate.tscn")
onready var NOT_Gate = preload("res://Scenes/GATE_Scenes/NOT_Gate.tscn")
onready var XOR_Gate = preload("res://Scenes/GATE_Scenes/XOR_Gate.tscn")
onready var Gate = OR_Gate

onready var WIRE_CREATION_MODULE = get_node("WireCreation")


func _ready():
	#Make the mouse cursor dissapear 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func raycast_input_pos():
	var rayLength = 1000
	var from = $Camera.project_ray_origin(input_pos)
	var to = from + $Camera.project_ray_normal(input_pos)*rayLength

	#Getting the orthoganol view
	var spaceState = get_world().direct_space_state
	var result
	#Send a ray out of camera to mouse, do not intersect with yourself
	if(selected == null):
		result = spaceState.intersect_ray(from, to, [self])
	else:
		result = spaceState.intersect_ray(from, to, [selected])
	var id = Vector3(-1, -1, -1)
	if(result.size() > 0):
		id = get_id(result["position"]-Vector3(0, 0.1, 0))
	
	return {"result" : result, "id" : id}
func get_id(pos):
	var scl = 1
	var idX = int(round(floor(pos.x)*scl))
	var idY = int(round(floor(pos.y)*scl))
	var idZ = int(round(floor(pos.z)*scl))
	return Vector3(idX, idY, idZ)
	
func is_pos_occupied(pos = Vector3(0, 0, 0)) -> bool:
	var sumOfResults = 0
	if(selected == null):
		print("Selected is null")
	else:
		var s = selected.get_node("CollisionShape").get_shape().get_extents()
		var rot = selected.desired_rot
		var co = abs(cos(rot))
		var si = abs(sin(rot))
		#Send a ray from each corner and center of selected straight down
		for dz in range(-1, 2):
			for dx in range(-1, 2):
				var from = selected.transform.origin + Vector3((s.x*co+s.z*si)*dx, -10, (s.z*co + s.x*si)*dz)*0.95
				var to = from + Vector3(0, 100, 0)
				var spaceState = get_world().direct_space_state
				var result = spaceState.intersect_ray(from, to, [selected], 1)
				if(result.size() > 0 and result['collider'].get_collision_layer_bit(2)):
					sumOfResults += len(result)
	
	return sumOfResults > 0

func update_input(delta):
	var moving = false
	
	#Modifying the input dot on the screen
	if(Input.is_action_pressed("move_input_pos_up")):
		desired_input_pos.y -= input_pos_move_dif*Input.get_action_strength("move_input_pos_up")
		moving = true
	if(Input.is_action_pressed("move_input_pos_down")):
		desired_input_pos.y += input_pos_move_dif*Input.get_action_strength("move_input_pos_down")
		moving = true
	if(Input.is_action_pressed("move_input_pos_right")):
		desired_input_pos.x += input_pos_move_dif*Input.get_action_strength("move_input_pos_right")
		moving = true
	if(Input.is_action_pressed("move_input_pos_left")):
		desired_input_pos.x -= input_pos_move_dif*Input.get_action_strength("move_input_pos_left")
		moving = true
	if(moving):
		if(Singleton.inputMode == Singleton.COMPUTER_MODE):
			Singleton.inputMode = Singleton.JOYSTICK_MODE
		if(selected != null):
			selected.at_position = false
			
	#Clamp the desired input pos to be inside the screen/viewport
	desired_input_pos.x = clamp(desired_input_pos.x, 0, get_viewport().size.x-circle_size.x)
	desired_input_pos.y = clamp(desired_input_pos.y, 0, get_viewport().size.y-circle_size.y)
	
	var input_pos_dif = (desired_input_pos-input_pos)*input_pos_move_snapiness*delta
	
	#If we are close enough, snap to the correct position
	if(input_pos_dif.length() < 0.005):
		input_pos = desired_input_pos
	else: #otherwise continue inching towards
		input_pos += input_pos_dif
	
	#Clamp the input position to the screen
	input_pos.x = clamp(input_pos.x, 0, get_viewport().size.x-circle_size.x)
	input_pos.y = clamp(input_pos.y, 0, get_viewport().size.y-circle_size.y)
	#move the graphics to the input position
	input_pos_link.rect_position = input_pos
	#If we are grabbing for an object
	if(selected != null and Singleton.gameMode == Singleton.BUILD_MODE):
		var res = raycast_input_pos()
		var resID = res['id']
		if(resID.x >= 0 and resID != prevID): #if we have hit a ground
			# Check if the space is occupied ========================================
				selected.set_desired_pos(Vector3(resID.x, 3, resID.z))
				
#Moves the camera position so that the player can move around the map		
func update_map_movement(delta):
	
	#Update the desired camera position based upon input
	if(Input.is_action_pressed("mv_foreward")):
		desired += Vector3(move_dif, 0, 0)*Input.get_action_strength("mv_foreward")
	if(Input.is_action_pressed("mv_backward")):
		desired += Vector3(-move_dif, 0, 0)*Input.get_action_strength("mv_backward")
	if(Input.is_action_pressed("mv_right")):
		desired += Vector3(0, 0, move_dif)*Input.get_action_strength("mv_right")
	if(Input.is_action_pressed("mv_left")):
		desired += Vector3(0, 0, -move_dif)*Input.get_action_strength("mv_left")

	# joystick camera movement
	if(Input.get_connected_joypads().size()>0 and Singleton.inputMode == Singleton.JOYSTICK_MODE):
		if(input_pos.x < cameraBorderWidth):
			var strength = (cameraBorderWidth - input_pos.x)/cameraBorderWidth
			desired += Vector3(0, 0, -move_dif)*strength
			input_pos.x += move_dif*strength*input_pos_move_snapiness
			desired_input_pos.x += move_dif*strength*input_pos_move_snapiness
		if(input_pos.x > get_viewport().size.x - cameraBorderWidth):
			var strength = (cameraBorderWidth - (get_viewport().size.x - input_pos.x))/cameraBorderWidth
			desired += Vector3(0, 0, move_dif)*strength
			input_pos.x -= move_dif*strength*input_pos_move_snapiness
			desired_input_pos.x -= move_dif*strength*input_pos_move_snapiness
			
		if(input_pos.y < cameraBorderWidth):
			var strength = (cameraBorderWidth - input_pos.y)/cameraBorderWidth
			desired += Vector3(move_dif, 0, 0)*strength
			input_pos.y += move_dif*strength*input_pos_move_snapiness
			desired_input_pos.y += move_dif*strength*input_pos_move_snapiness
		if(input_pos.y > get_viewport().size.y - cameraBorderWidth):
			var strength = (cameraBorderWidth - (get_viewport().size.y - input_pos.y))/cameraBorderWidth
			desired += Vector3(-move_dif, 0, 0)*strength
			input_pos.y -= move_dif*strength*input_pos_move_snapiness
			desired_input_pos.y -= move_dif*strength*input_pos_move_snapiness
		
			
	#Zooming in and out
	if(Input.is_action_pressed("zoom_in")):
		desired += $Camera.transform.basis.z*move_dif * -1
	if(Input.is_action_pressed("zoom_out")):
		desired += $Camera.transform.basis.z*move_dif

	#Linearly interpolate bewteen current position and desired position
	var dif = (desired-transform.origin)*move_snapiness*delta
	translate(dif)

func _process(delta):
	if(can_move_input_pos):
		update_input(delta)
	if(can_move):
		update_map_movement(delta)
	
func _input(event):
	#Update the input position to be the mouse position
	if(event is InputEventMouseMotion and can_move_input_pos):
		input_pos += event.relative
		desired_input_pos += event.relative
		if(Singleton.inputMode == 1):
			Singleton.inputMode = 0
	
	if(Input.is_action_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		can_move = false
		can_move_input_pos = false
		
	#If we are clicking back into the game from being outside of it
	if(Input.is_action_just_pressed("select") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		can_move = true
		can_move_input_pos = true 
		
	if(Input.is_action_just_pressed("select") and Singleton.gameMode == Singleton.BUILD_MODE):
		if(selected == null):
			var res = raycast_input_pos()
			if(res['id'].x >= 0 and res['result']['collider'].get_collision_layer_bit(0)):
				selected = res['result']['collider']
				selected.set_selected(true)
		else:
			if(not is_pos_occupied()):
				selected.set_selected(false)
				selected = null
	
	if(Input.is_action_just_pressed("rotate") and selected != null and Singleton.gameMode == Singleton.BUILD_MODE):
		selected.rot_90()
	
	if(Input.is_action_just_pressed("switch_mode")):
		# if there is anything in the player's hand, remove it 
		if(selected != null):
				if(not selected.is_in_group("Indestructable")):
					#Delete the block in hand			
					selected.get_parent().remove_child(selected)
					selected = null
				else:
					selected.set_selected(false)
					selected = null
		if(WIRE_CREATION_MODULE.current_wire != null):
				WIRE_CREATION_MODULE.current_wire.get_parent().remove_child(WIRE_CREATION_MODULE.current_wire)
				WIRE_CREATION_MODULE.current_wire = null
				
		# loop through the modes
		if(Singleton.gameMode == Singleton.BUILD_MODE):
			Singleton.gameMode = Singleton.WIRE_MODE
			print("Wire Mode")
		elif(Singleton.gameMode == Singleton.WIRE_MODE):
			Singleton.gameMode = Singleton.INTERACT_MODE
			print("Interact Mode")	
		elif(Singleton.gameMode == Singleton.INTERACT_MODE):
			Singleton.gameMode = Singleton.BUILD_MODE
			print("Build Mode")
			
# function that changes which gate spaws upon creation
func updateGateMode():
	if(Singleton.gateMode == 0):
		Gate = OR_Gate
	elif(Singleton.gateMode == 1):
		Gate = AND_Gate
	elif(Singleton.gateMode == 2):
		Gate = NOT_Gate
	elif(Singleton.gateMode == 3):
		Gate = XOR_Gate
		
			

	
	