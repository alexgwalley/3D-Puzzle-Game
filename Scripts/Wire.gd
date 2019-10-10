extends Spatial

var desiredPos:Vector3 = Vector3(0, 0, 0)
var desiredDir:Vector3 = Vector3(0, 0, 0)
var p1 = null
var p1Path = ""
var p2 = null
var p2Path = ""
var set_once = false

var charge = 0

#Materials
onready var onMat  = load("res://Materials/wire_on_material.tres")
onready var offMat = load("res://Materials/wire_off_material.tres")
func _ready():
	var m = get_node("CSGMesh").mesh.duplicate(true)
	var mat = get_node("CSGMesh").mesh.surface_get_material(0).duplicate()
	get_node("CSGMesh").mesh = m
	get_node("CSGMesh").mesh.material = mat
	
func set_height(h:float):
	self.get_node("CSGMesh").scale = Vector3(0.5, 0.5, 2*h)
	
func set_parents(a, aPath, b, bPath):
	p1 = a
	p1Path = aPath
	p2 = b 
	p2Path = bPath
	set_once = true

func handle_parents():
	if(set_once and 
	   not get_parent().get_parent().get_parent().find_node("Gates").has_node(p1Path) or
	   not get_parent().get_parent().get_parent().find_node("Gates").has_node(p2Path)):
		get_parent().remove_child(self)
	

func update_position():
	set_position(p1.transform.origin, p2.transform.origin)
	set_height((p1.transform.origin-p2.transform.origin).length())
	
func set_position(pos1:Vector3, pos2:Vector3):
	
	#handing position
	var middle = (pos1+pos2)*0.5
	desiredPos = Vector3(middle.x, 1, middle.z)
	
	
	#handling rotation
	var dir = (Vector3(pos2.x, 0, pos2.z)-Vector3(pos1.x, 0, pos1.z))
	desiredDir = dir
	var init = Quat(transform.basis)
	var final = Quat(transform.looking_at(transform.origin + dir, Vector3(0, 1, 0)).basis)
	#transform.basis = Basis(init.slerp(final, 1))
	look_at_from_position(desiredPos, transform.origin+dir, Vector3.UP)
	
func update_mat():
	if(charge > 0):
		self.get_node("CSGMesh").mesh.material.albedo_color = onMat.albedo_color
	if(charge == 0):
		self.get_node("CSGMesh").mesh.material.albedo_color = offMat.albedo_color
	
func _process(delta):
	if(p1 != null):
		update_position()
		#print("p1: %d p2: %d" % [p1.charge, p2.charge])
		charge = p2.charge
		update_mat()
	if(set_once and p1.connection_exists(p2) == false):
		p1.remove_connection(p2)
		p2.remove_connection(p1)
		get_parent().remove_child(self)
	
		