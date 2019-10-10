extends Spatial

#modes
const BUILD_MODE = 0
const WIRE_MODE = 1
const INTERACT_MODE = 2

var mode = WIRE_MODE

#Input
var move_dif = 0.5
var move_snapiness = 8
var can_move = true
var desired = transform.origin

var can_move_input_pos = true
var input_pos = Vector2(0, 0)
var desired_input_pos = Vector2(0, 0)
var input_pos_move_dif = 8
var input_pos_move_snapiness = 10
onready var circle_size = get_parent().get_node("Mouse/TextureRect").rect_size*get_parent().get_node("Mouse/TextureRect").rect_scale
onready var input_pos_link = get_parent().get_node("Mouse/TextureRect")

#Grid
onready var gridSize = 2
var prevID = Vector3(0, 0, 0)

#Selection and Moving
var selected = null

#Placing Blocks
onready var OR_Gate = preload("res://Scenes/GATE_Scenes/AND_Gate.tscn")

#Wire creation
var selected_wire_holder = null
var current_wire = null
onready var wire = preload("res://Scenes/Wire and Interaction/Wire.tscn")
onready var wire_holder = preload("res://Scenes/Wire and Interaction/Wire Holder.tscn")


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
	if(moving and selected != null):
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
	if(selected != null and mode == BUILD_MODE):
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
	
	if(mode == WIRE_MODE):
		handle_wire_making()
	
func _input(event):
	#Update the input position to be the mouse position
	if(event is InputEventMouseMotion and can_move_input_pos):
		input_pos += event.relative
		desired_input_pos += event.relative
	
	if(Input.is_action_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		can_move = false
		can_move_input_pos = false
		
	#If we are clicking back into the game from being outside of it
	if(Input.is_action_just_pressed("select") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		can_move = true
		can_move_input_pos = true 
		
	if(Input.is_action_just_pressed("select") and mode == BUILD_MODE):
		if(selected == null):
			var res = raycast_input_pos()
			if(res['id'].x >= 0 and res['result']['collider'].get_collision_layer_bit(0)):
				selected = res['result']['collider']
				selected.set_selected(true)
		else:
			if(not is_pos_occupied()):
				selected.set_selected(false)
				selected = null
	
	if(Input.is_action_just_pressed("rotate") and selected != null and mode == BUILD_MODE):
		selected.rot_90()
	
	#If there is no object in hand and the user clicks to create a block
	#TEMPORARY
	if(Input.is_action_just_pressed("create_cube") and selected == null and mode == BUILD_MODE):
		var c = OR_Gate.instance()
		c.set_selected(true)
		selected = c
		var cast = raycast_input_pos()
		if(cast['id'].x >= 0):
			c.set_desired_pos(get_id(cast['result']['position']))
		get_parent().get_node("Gates").add_child(c)
	
	if(Input.is_action_just_pressed("create_wire_holder") and selected == null and mode == BUILD_MODE):
		var wh = wire_holder.instance()
		wh.set_selected(true)
		selected = wh
		var cast = raycast_input_pos()
		if(cast['id'].x >= 0):
			wh.set_desired_pos(get_id(cast['result']['position']))
		get_parent().get_node("Wire Stuff/Wire Holders").add_child(wh)
	
	if(selected != null and Input.is_action_just_pressed("quit")):
		if(mode == BUILD_MODE):
			#Delete the block in hand			
			selected.get_parent().remove_child(selected)
			selected = null
			#Make the wires check if their parent was MURDERED
			for child in get_parent().find_node("Wire Stuff").find_node("Wires").get_children():
				child.handle_parents()
			for child in get_parent().find_node("Wire Stuff").find_node("Wire Holders").get_children():
				child.handle_connections_dead()
			for child in get_parent().get_node("Inputs").get_children():
				child.handle_connections_dead()
			for child in get_parent().get_node("Gates").get_children():
				child.handle_connections_dead()
			
		if(mode == WIRE_MODE):
			current_wire.get_parent().remove_child(current_wire)
			current_wire = null
			selected = null
			
	if(Input.is_action_just_pressed("switch_mode")):
		if(mode == BUILD_MODE):
			mode = WIRE_MODE
			print("Wire Mode")
			if(selected != null):
				#Delete the block in hand			
				selected.get_parent().remove_child(selected)
				selected = null
				
		elif(mode == WIRE_MODE):
			mode = INTERACT_MODE
			print("Interact Mode")
			if(current_wire != null):
				current_wire.get_parent().remove_child(current_wire)
				current_wire = null
		elif(mode == INTERACT_MODE):
			mode = BUILD_MODE
			print("Build Mode")
			
		selected = null
			
		
	if(Input.is_action_just_pressed("select") and mode == INTERACT_MODE and selected == null):
		var res = raycast_input_pos()
		if(res['id'].x >= 0 and res['result']['collider'].get_collision_layer_bit(0) and not res['result']['collider'].get_collision_layer_bit(2) 
		   and res['result']['collider'].is_in_group("Input")):
			var obj = res['result']['collider']
			selected = obj
			obj.set_charge(obj, 1)
			
	if(Input.is_action_just_released("select") and mode == INTERACT_MODE and selected != null):
		selected.set_charge(selected, 0)
		selected = null
			
	
func handle_wire_making():
	if(Input.is_action_just_pressed("select")):
			var res = raycast_input_pos()
			if(res['id'].x >= 0 and res['result']['collider'].get_collision_layer_bit(0) and res['result']['collider'].is_in_group("Connectable")):
				if(selected == null):
					print("selected wire")
					selected = res['result']['collider']
					current_wire = null
					current_wire = wire.instance()
					get_parent().get_node("Wire Stuff/Wires").add_child(current_wire, true)
				else:
					var r1 = selected.handle_connection(res['result']['collider'], res['result']['collider'].get_path(), true)
					var r2 = res['result']['collider'].handle_connection(selected, selected.get_path(), false)
					
					if(r1>0 and r2>0):
						current_wire.set_parents(selected, selected.get_path(), res['result']['collider'], res['result']['collider'].get_path()) 
						print("made connection")
						selected = null
						current_wire = null
					
					if(r1 == -1 or r2 == -1):
						current_wire.get_parent().remove_child(current_wire)
						selected = null
						current_wire = null
					
	if(selected != null and current_wire != null):
		var mousePos3D = raycast_input_pos()['result']['position']
		current_wire.set_position(selected.transform.origin, mousePos3D)
		var h = mousePos3D-selected.transform.origin
		current_wire.set_height(h.length())
	
	pass
	
	