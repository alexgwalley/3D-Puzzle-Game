extends Spatial

#Wire creation
var selected_wire_holder = null
var current_wire = null
onready var wire = preload("res://Scenes/Wire and Interaction/Wire.tscn")
onready var wire_holder = preload("res://Scenes/Wire and Interaction/Wire Holder.tscn")

func _process(delta):
	if(Singleton.gameMode == Singleton.WIRE_MODE):
		handle_wire_making()
		
	if( Input.is_action_just_pressed("create_wire_holder") 
	and get_parent().selected == null 
    and Singleton.gameMode == Singleton.BUILD_MODE ):
		create_wire_holder()
		
# function that creates a new wire holder and places it 
# in a 3D position that the player is currently pointing at
# --Note: if the player is not pointing at anything, sets the wire holder to the origin
func create_wire_holder():
	var wh = wire_holder.instance() # the newly instanced wire holder
	wh.set_selected(true) 
	get_parent().selected = wh
	
	var cast = get_parent().raycast_input_pos() 
	if(cast['id'].x >= 0): # hit something. Note: if it does not hit something, its position will be (0, 0, 0) (origin)
		# snap the wire holder's position to the grid
		wh.set_desired_pos(get_parent().get_id(cast['result']['position'])) 
	
	# add the wire holder to the scene
	get_parent().get_parent().get_node("Wire Stuff/Wire Holders").add_child(wh) 

# function that creates wires and makes their connections to interactables
func handle_wire_making():
	var selected = get_parent().selected
	if(Input.is_action_just_pressed("select")): # the player wants to click something
		var res = get_parent().raycast_input_pos()
		if(res['id'].x >= 0): # we hit something, id = -1 when nothing was hit
			var clicked = res['result']['collider'] # get the object we clicked on
			# collision layer bit 0 is Interactable
			if(clicked.get_collision_layer_bit(0) and clicked.is_in_group("Connectable")):
				if(selected == null): # if the player does not have anything in their hands, make a wire holder
					
					get_parent().selected = clicked 
					current_wire = wire.instance() # instance a new wire
					
					# add the wire to the scene
					get_parent().get_parent().get_node("Wire Stuff/Wires").add_child(current_wire, true)
				else:
					# results from the handle connection function
					# 1 means the connection was created
					# 0 means the user attempts to make a connection with the same wire holder
					# -1 means that a connection was removed
					var r1 = selected.handle_connection(clicked, clicked.get_path(), true)
					var r2 = clicked.handle_connection(selected, selected.get_path(), false)
					
					if(r1 >= 1 and r2 >= 1): # connection made!
						
						current_wire.set_parents(selected, selected.get_path(), clicked, clicked.get_path()) 
						
						get_parent().selected = null
						current_wire = null
					
					if(r1 <= -1 or r2 <= -1): # connection removed
						if(current_wire != null):
							current_wire.queue_free() # delete the current wire
						
						get_parent().selected = null
						current_wire = null
						
	# update the position of the wire in hand if it is connected to something
	if(selected != null and current_wire != null):
		var res = get_parent().raycast_input_pos()
		if(res['id'].x >= 0): # we hit something
			
			var mousePos3D = res['result']['position'] 
			current_wire.set_position(selected.transform.origin, mousePos3D)
			
			var d = mousePos3D-selected.transform.origin # the vector pointing from selected to the mousePos3D
			current_wire.set_height(d.length())
		if(Input.is_action_pressed("delete")):
			current_wire.queue_free()
			current_wire = null