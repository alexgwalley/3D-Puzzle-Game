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
	self.p1Path = aPath
	p2 = b 
	self.p2Path = bPath
	set_once = true

func handle_connections_dead():
	if(set_once and 
	   (not get_parent().get_parent().find_node("Gates").has_node(p1Path) or
	   not get_parent().get_parent().find_node("Gates").has_node(p2Path))):
		queue_free()
	

func update_position():
	var puzzle1 = p1.get_parent().get_parent()
	var puzzle2 = p2.get_parent().get_parent()
	set_position(p1.transform.origin+puzzle1.transform.origin, p2.transform.origin+puzzle2.transform.origin)
	set_height(((p1.transform.origin+puzzle1.transform.origin)-(p2.transform.origin+puzzle2.transform.origin)).length())
	
func set_position(pos1:Vector3, pos2:Vector3):
	#handing position
	var middle = ((pos1)+pos2)*0.5
	desiredPos = Vector3(middle.x, 1, middle.z)
	
	#handling rotation
	var dir = (Vector3(pos2.x, 0, pos2.z)-Vector3(pos1.x, 0, pos1.z))
	look_at_from_position(desiredPos, transform.origin+get_parent().get_parent().transform.origin + dir, Vector3.UP)
	
func update_mat():
	if(charge > 0):
		self.get_node("CSGMesh").mesh.material.albedo_color = onMat.albedo_color
	if(charge == 0):
		self.get_node("CSGMesh").mesh.material.albedo_color = offMat.albedo_color
	
func _process(delta):
	if(self.p1 != null):
		update_position()		
		charge = int(self.p1.charge>0)
		update_mat()
	if(set_once and (not p1.connection_exists(p2) and not p2.connection_exists(p1))):
		queue_free()
	
		