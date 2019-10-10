extends "res://Scripts/TestCube.gd"


var charge = 0
var outputConnection = null
var outputConnectionPath = ""

#Materials
var onMat = load("res://Materials/wire_on_material.tres")
var offMat = load("res://Materials/wire_off_material.tres")

func set_charge(caller, a: int, depth=0):
	charge = a
	depth += 1
	if(depth > 50):
		return
	if(outputConnection != null and depth < 100):
		outputConnection.set_charge(self, charge, depth)
	handle_material()
		
func connection_exists(conn):
	if(outputConnection == conn):
		return true
	return false
		
func handle_connection(conn, connPath, parent=true) -> int:
	if(conn == outputConnection):
		outputConnection = null
		return -1
	if(outputConnection != null):
		return 0
	outputConnection = conn
	outputConnectionPath = connPath	
	return 1
	
func handle_connections_dead():
	if(not get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(outputConnectionPath) and
	   not get_parent().get_parent().find_node("Gates").has_node(outputConnectionPath)):
			outputConnection = null
	
func remove_connection(conn):
	if(outputConnection == conn):
		outputConnection = null
func handle_material():
	if(charge == 1):
		self.get_node("CSGMesh").mesh.material.albedo_color = onMat.albedo_color
		#print("updating material on")
	if(charge == 0):
		self.get_node("CSGMesh").mesh.material.albedo_color = offMat.albedo_color
		#print("updating material off")
		
# Called when the node enters the scene tree for the first time.
func _ready():
	var m = get_node("CSGMesh").mesh.duplicate(true)
	var mat = get_node("CSGMesh").mesh.surface_get_material(0).duplicate()
	get_node("CSGMesh").mesh = m
	get_node("CSGMesh").mesh.material = mat
	

func _on_Area_body_entered(body):
	if(body != self):
		set_charge(self, 1)
func _on_Area_body_exited(body):
	if(body != self):
		set_charge(self, 0)
