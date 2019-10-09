extends RigidBody

var desired_pos: Vector3 = Vector3(0, 0, 0)
var desired_rot: float = 0
var at_position: bool = true  
var at_rotation: bool = true
var selected: bool = false
var precision: float = 0.0025
var type = 0


# Called when the node enters the scene tree for the first time.
func set_selected(b:bool) -> void:
	selected = b
	sleeping = b
	
	if(b == false): #Set the rotation directly to desired
		for child in get_children():
			var init = Quat(child.transform.basis)
			var final = Quat(child.transform.rotated(Vector3(0, 1, 0), desired_rot-child.rotation.y).basis)
			child.transform.basis = Basis(init.slerp(final, 1))
		at_rotation = true
	
func set_rot(rot:float):
	desired_rot = rot
	for child in get_children():
		var init = Quat(child.transform.basis)
		var final = Quat(child.transform.rotated(Vector3(0, 1, 0), rot-child.rotation.y).basis)
		child.transform.basis = Basis(init.slerp(final, 1))
	at_rotation = true
func clean_rot(rot:float) -> float:
	var r = rot
	while(r >= PI*2.0):
		r -= PI*2.0
	return r
	

	
func rot_90() -> void:
	at_rotation = false
	desired_rot = clean_rot(desired_rot)+deg2rad(90)
	
func _process(delta):
	if(not at_position):
		var dif = (desired_pos - transform.origin)*delta*10
		translate(dif)
		if(dif.length() < precision):
			at_position = true
	
	if(not at_rotation):
		for child in get_children():
			var init = Quat(child.transform.basis)
			var final = Quat(child.transform.rotated(Vector3(0, 1, 0), desired_rot-child.rotation.y).basis)
			child.transform.basis = Basis(init.slerp(final, 0.1))
			if(desired_rot-child.rotation.y < precision):
				at_rotation = true
		
	if (sleeping == true and selected == false and at_position and at_rotation):
		sleeping = false
	
	
func set_desired_pos(pos: Vector3) -> void:
	desired_pos = pos
	at_position = false
	
