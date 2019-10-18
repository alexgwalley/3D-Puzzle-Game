extends NinePatchRect

var hovered_over = false
export var selected = false

export var normal_texture: ImageTexture
export var hovered_texture: ImageTexture
export var selected_texture: ImageTexture
export var mode: int

func _process(delta):
	if(Input.is_action_just_pressed("select") and hovered_over and Singleton.inputMode == Singleton.COMPUTER_MODE):
		set_selected()
		Singleton.gateMode = mode
		get_parent().get_parent().get_node("PlayerControl").updateGateMode()
		
				
func set_selected():
	selected = true
	update_texture()
	for child in get_parent().get_children():
			if(child != self):
				child.selected = false
				child.update_texture()						
func update_texture():
	if(selected):
		get_node("Border").texture = selected_texture
	elif(hovered_over):
		get_node("Border").texture = hovered_texture
	else:
		get_node("Border").texture = normal_texture
		
