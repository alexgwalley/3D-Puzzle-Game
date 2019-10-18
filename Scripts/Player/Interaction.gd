extends Spatial

func _process(delta):
	var selected = get_parent().selected
	
	
	if( Input.is_action_just_pressed("select") 
	and Singleton.gameMode == Singleton.INTERACT_MODE # the player wants to interact
	and selected == null ):   # nothing selected
		
		var res = get_parent().raycast_input_pos()
		
		if( res['id'].x >= 0 										 # the raycast hit something
		and res['result']['collider'].get_collision_layer_bit(0)     # is interactable 
		and not res['result']['collider'].get_collision_layer_bit(2) # does not take-space
		and res['result']['collider'].is_in_group("Input") ): 		 # is in input group
		
			var obj = res['result']['collider']
			get_parent().selected = obj
			if(not obj.blockOnTop): # if the button does not have a block on top
				obj.set_charge(1) 	# turn the button on and pass the charges
				if(obj.animator):
					obj.animator.play("ReleasedToPressed")		
			
	if( Input.is_action_just_released("select") # the player releases the selection
	and Singleton.gameMode == Singleton.INTERACT_MODE 
	and selected != null 						# the player is selecting something
	and not selected.blockOnTop ): 				# there is not a block on top of the button
		selected.set_charge(0) 					# turn the button off and pass the charge
		if(selected.animator):
			selected.animator.play("PressedToReleased")		
		get_parent().selected = null 			# de-select the button