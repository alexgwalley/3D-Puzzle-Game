extends Spatial
 
onready var WIRE_CREATION_MODULE = load("res://Scripts/Player/WireCreation.gd")

func _process(delta):
	var selected = get_parent().selected

	# if there is no object in hand and the user clicks to create a block
	if( Input.is_action_just_pressed("create_cube") 
	and selected == null 
	and Singleton.gameMode == Singleton.BUILD_MODE ):
		
		create_gate()

	if( selected != null 								# the player has something in hand
	and Input.is_action_just_pressed("delete")			# the player is trying to delete a block
	and Singleton.gameMode == Singleton.BUILD_MODE								
	and not selected.is_in_group("Indestructable") ): 	# the object is destructable
			delete_selected(selected)
			
func delete_selected(selected):
	# delete the block in hand			
	selected.get_parent().remove_child(selected) # delete object from scene
	get_parent().selected = null
	
	# check if parents are still alive...if not, remove the connection
	for child in get_parent().get_parent().find_node("Wire Stuff").find_node("Wires").get_children():
		child.handle_parents()
	for child in get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").get_children():
		child.handle_connections_dead()
	for child in get_parent().get_parent().get_node("Inputs").get_children():
		child.handle_connections_dead()
	for child in get_parent().get_parent().get_node("Gates").get_children():
		child.handle_connections_dead()
	
	if(Singleton.gameMode == Singleton.WIRE_MODE):
		# remove the current_wire
		WIRE_CREATION_MODULE.current_wire.get_parent().remove_child(WIRE_CREATION_MODULE.current_wire)
		WIRE_CREATION_MODULE.current_wire = null
		get_parent().selected = null	

func create_gate():
	
	var g = get_parent().Gate.instance() # instance a new gate
	g.set_selected(true)
	get_parent().selected = g
	
	var cast = get_parent().raycast_input_pos() # send out a ray from the mouse
	
	if(cast['id'].x >= 0): # the raycast hit something
		g.set_desired_pos(get_parent().get_id( cast['result']['position']) )	# snaps the gate to the grid
		
	get_parent().get_parent().get_node("Gates").add_child(g) 					# add the new gate to the scene