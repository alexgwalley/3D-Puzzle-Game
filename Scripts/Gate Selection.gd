extends Control

var mouseSensitivity = 0.3
var mouseWheelPosition = 0
var roundMousePosition = 0

func _input(event):
	
	# joysticks
	if(Input.is_action_just_pressed("select_left")):
		if(Singleton.gateMode - 1 >= 0):
			Singleton.gateMode -= 1
		else:
			Singleton.gateMode = Singleton.numberOfGates-1
		get_parent().get_node("PlayerControl").updateGateMode()
		updateGateGUISelected()
		

	if(Input.is_action_just_pressed("select_right")):
		if(Singleton.gateMode + 1 < Singleton.numberOfGates):
			Singleton.gateMode += 1
		else:
			Singleton.gateMode = 0
		get_parent().get_node("PlayerControl").updateGateMode()
		updateGateGUISelected()
	
	# mouse wheel
	if(event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN):
		mouseWheelPosition += mouseSensitivity
		updateMouseWheelPosition()
		updateSelectedFromMouseWheelPosition()
		updateGateGUISelected()
		
	if(event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP):
		mouseWheelPosition -= mouseSensitivity
		updateMouseWheelPosition()
		updateSelectedFromMouseWheelPosition()
		updateGateGUISelected()

func updateMouseWheelPosition():
	if(mouseWheelPosition > Singleton.numberOfGates - 1):
		mouseWheelPosition = 0
	elif(mouseWheelPosition < 0):
		mouseWheelPosition = Singleton.numberOfGates - 1
		
	roundMousePosition = round(mouseWheelPosition)

func updateSelectedFromMouseWheelPosition():
	Singleton.gateMode = roundMousePosition

func updateGateGUISelected():
	for child in get_children():
		if(child.mode == Singleton.gateMode):
			child.set_selected()
		