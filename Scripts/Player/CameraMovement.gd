extends Node

#Input
var move_dif = 0.5
onready var desired = get_parent().transform.origin
var move_snapiness = 10
var cameraBorderWidth = 100
var input_pos_move_snapiness = 10

func update_map_movement(delta):
	
	#Update the desired camera position based upon input
	if(Singleton.gameMode != Singleton.MAP_MODE):
		if(Input.is_action_pressed("mv_foreward")):
			desired += Vector3(move_dif, 0, 0)*Input.get_action_strength("mv_foreward")
		if(Input.is_action_pressed("mv_backward")):
			desired += Vector3(-move_dif, 0, 0)*Input.get_action_strength("mv_backward")
		if(Input.is_action_pressed("mv_right")):
			desired += Vector3(0, 0, move_dif)*Input.get_action_strength("mv_right")
		if(Input.is_action_pressed("mv_left")):
			desired += Vector3(0, 0, -move_dif)*Input.get_action_strength("mv_left")
		#Clamp the camera pos within current puzzle
		var size = Singleton.current_puzzle.get_node("Floor/CollisionShape").scale
		var puzzle_pos = Singleton.current_puzzle.transform.origin
		desired.x = clamp(desired.x, puzzle_pos.x - size.x*1.5, puzzle_pos.x + size.x*0.5)
		desired.z = clamp(desired.z, puzzle_pos.z - size.z*1.5, puzzle_pos.z)
		
	# joystick camera movement
	if(Input.get_connected_joypads().size()>0 and Singleton.inputMode == Singleton.JOYSTICK_MODE):
		if(Singleton.input_pos.x < cameraBorderWidth):
			var strength = (cameraBorderWidth - Singleton.input_pos.x)/cameraBorderWidth
			desired += Vector3(0, 0, -move_dif)*strength
			Singleton.input_pos.x += move_dif*strength*input_pos_move_snapiness
			Singleton.desired_input_pos.x += move_dif*strength*input_pos_move_snapiness
		if(Singleton.input_pos.x > get_viewport().size.x - cameraBorderWidth):
			var strength = (cameraBorderWidth - (get_viewport().size.x - Singleton.input_pos.x))/cameraBorderWidth
			desired += Vector3(0, 0, move_dif)*strength
			Singleton.input_pos.x -= move_dif*strength*input_pos_move_snapiness
			Singleton.desired_input_pos.x -= move_dif*strength*input_pos_move_snapiness
			
		if(Singleton.input_pos.y < cameraBorderWidth):
			var strength = (cameraBorderWidth - Singleton.input_pos.y)/cameraBorderWidth
			desired += Vector3(move_dif, 0, 0)*strength
			Singleton.input_pos.y += move_dif*strength*input_pos_move_snapiness
			Singleton.desired_input_pos.y += move_dif*strength*input_pos_move_snapiness
		if(Singleton.input_pos.y > get_viewport().size.y - cameraBorderWidth):
			var strength = (cameraBorderWidth - (get_viewport().size.y - Singleton.input_pos.y))/cameraBorderWidth
			desired += Vector3(-move_dif, 0, 0)*strength
			Singleton.input_pos.y -= move_dif*strength*input_pos_move_snapiness
			Singleton.desired_input_pos.y -= move_dif*strength*input_pos_move_snapiness
		
			
	if((Input.is_action_just_pressed("toggle_map") 
	or (Singleton.camera_mode == Singleton.MAP_MODE and 
		Input.is_action_just_pressed("select")))
		and Singleton.gameMode != Singleton.CHECKING_MODE):
		var selected = get_parent().selected
		# unselect the Selected block
		if( selected != null): 	# the object is destructable
			get_parent().get_node("BlockCreation").delete_selected(selected)
		
		if(Singleton.camera_mode == Singleton.PLAY_MODE):
			desired += get_parent().get_node("Camera").transform.basis.z*50
			Singleton.camera_mode = Singleton.MAP_MODE
			Singleton.gameMode = Singleton.MAP_MODE
		elif(Singleton.camera_mode == Singleton.MAP_MODE):
			desired += get_parent().get_node("Camera").transform.basis.z*-50
			var size = Singleton.current_puzzle.get_node("Floor/CSGMesh").scale
			desired = Vector3(Singleton.current_puzzle.transform.origin.x-size.x, desired.y, Singleton.current_puzzle.transform.origin.z-size.z)
			Singleton.camera_mode = Singleton.PLAY_MODE
			Singleton.gameMode = Singleton.BUILD_MODE
		
		get_parent().get_parent().get_node("GUI/Mode GUI").updateModeGUI()

	# linearly interpolate bewteen current position and desired position
	var dif = (desired-get_parent().transform.origin)*move_snapiness*delta
	get_parent().translate(dif)

func reset_camera():
	var size = Singleton.current_puzzle.get_node("Floor/CollisionShape").scale
	desired = Vector3(Singleton.current_puzzle.transform.origin.x-size.x*2, desired.y, Singleton.current_puzzle.transform.origin.z-size.z)

func _process(delta):
	update_map_movement(delta)