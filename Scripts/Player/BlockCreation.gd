extends Spatial
 
onready var WIRE_CREATION_MODULE = load("res://Scripts/Player/WireCreation.gd")

func _process(delta):
	var selected = get_parent().selected

	# if there is no object in hand and the user clicks to create a block
	if( Input.is_action_just_pressed("create_cube") 
	and selected == null 
	and Singleton.gameMode == Singleton.BUILD_MODE ):
		if(able_to_place_gate(Singleton.gateMode)):
			create_gate()
			update_number_of_gates(Singleton.gateMode)
			get_parent().get_parent().get_node("Selection GUI").updateGateGUINumber()

	if( selected != null 								# the player has something in hand
	and Input.is_action_just_pressed("delete")			# the player is trying to delete a block
	and Singleton.gameMode == Singleton.BUILD_MODE								
	and not selected.is_in_group("Indestructable") ): 	# the object is destructable
			delete_selected(selected)
			
func delete_selected(selected):
	
	if(selected.is_in_group("Indestructable")):
		selected.set_selected(false)
		get_parent().selected = null
		return
	
	if(selected.type == Singleton.OR_GATE_TYPE 
	and Singleton.current_puzzle.numberOfORGates + 1 <= Singleton.current_puzzle.maxNumberOfORGates):
		Singleton.current_puzzle.numberOfORGates += 1
	elif(selected.type == Singleton.AND_GATE_TYPE 
	and Singleton.current_puzzle.numberOfANDGates + 1 <= Singleton.current_puzzle.maxNumberOfANDGates):
		Singleton.current_puzzle.numberOfANDGates += 1
	elif(selected.type == Singleton.NOT_GATE_TYPE 
	and Singleton.current_puzzle.numberOfNOTGates + 1 <= Singleton.current_puzzle.maxNumberOfNOTGates):
		Singleton.current_puzzle.numberOfNOTGates += 1
	elif(selected.type == Singleton.XOR_GATE_TYPE 
	and Singleton.current_puzzle.numberOfXORGates + 1 <= Singleton.current_puzzle.maxNumberOfXORGates):
		Singleton.current_puzzle.numberOfXORGates += 1
	get_parent().get_parent().get_node("Selection GUI").updateGateGUINumber()
	# delete the block in hand			
	selected.get_parent().remove_child(selected) # delete object from scene
	get_parent().selected = null
	
	# check if parents are still alive...if not, remove the connection
	for child in Singleton.current_puzzle.find_node("Wire Stuff").get_children():
		child.handle_connections_dead()
	for child in Singleton.current_puzzle.get_node("Inputs").get_children():
		child.handle_connections_dead()
	for child in Singleton.current_puzzle.get_node("Gates").get_children():
		child.handle_connections_dead()

func create_gate():
	var g = get_parent().Gate.instance() 					# instance a new gate
	Singleton.current_puzzle.get_node("Gates").add_child(g) # add the new gate to the scene
	g.set_selected(true)
	get_parent().selected = g
	
	var cast = get_parent().raycast_input_pos() # send out a ray from the mouse
	
	if(cast['id'].x >= 0): 														# the raycast hit something
		g.set_desired_pos(get_parent().get_id( cast['result']['position']) )	# snaps the gate to the grid
	
	 					
						
func able_to_place_gate(type):
	if(type == Singleton.OR_GATE_TYPE  and Singleton.current_puzzle.numberOfORGates - 1 >= 0):
		return true
	if(type == Singleton.AND_GATE_TYPE and Singleton.current_puzzle.numberOfANDGates - 1 >= 0):
		return true
	if(type == Singleton.NOT_GATE_TYPE and Singleton.current_puzzle.numberOfNOTGates - 1 >= 0):
		return true
	if(type == Singleton.XOR_GATE_TYPE and Singleton.current_puzzle.numberOfXORGates - 1 >= 0):
		return true
		
								
func update_number_of_gates(type):
	if(type == Singleton.OR_GATE_TYPE):
		Singleton.current_puzzle.numberOfORGates -= 1
	elif(type == Singleton.AND_GATE_TYPE):
		Singleton.current_puzzle.numberOfANDGates -= 1
	elif(type == Singleton.NOT_GATE_TYPE):
		Singleton.current_puzzle.numberOfNOTGates -= 1
	elif(type == Singleton.XOR_GATE_TYPE):
		Singleton.current_puzzle.numberOfXORGates -= 1
		
		
		
		
		
		
		
		