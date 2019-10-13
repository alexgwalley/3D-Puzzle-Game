extends "res://Scripts/TestCube.gd"

var charge = 0
var outputConnection = null
var outputConnectionPath = ""

var is_source = false

#Materials
var onMat = load("res://Materials/wire_on_material.tres")
var offMat = load("res://Materials/wire_off_material.tres")

func set_charge(a: int, depth=0):
	depth += 1	
	if(depth > 50):
		return
		
	if(a <= 0):
		self.charge = 0
	else:
		self.charge = 1
	
	if(outputConnection != null):
		outputConnection.set_charge(a)
		outputConnection.pass_charge()
	handle_material()
	
func pass_charge():
	if(outputConnection != null):
		outputConnection.update_charge()
		
func connection_exists(conn):
	if(outputConnection == conn):
		return true
	return false
		
func output_connection_exists(conn):
	if(outputConnection == conn):
		return true
	return false
		
func handle_connection(conn, connPath, parent=true) -> int:
	if(parent == false):
		print("rejected")
		return 0
	if(conn == outputConnection):
		remove_connection(conn)
		return -1
	if(outputConnection != null):
		return 0
	outputConnection = conn
	outputConnectionPath = connPath	
	return 1
	
func handle_connections_dead():
	if(not get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(outputConnectionPath) and
	   not get_parent().get_parent().find_node("Gates").has_node(outputConnectionPath)):
			remove_connection(outputConnection)
	
func remove_connection(conn):
	if(outputConnection == conn):
		outputConnection = null
		outputConnectionPath = ""
		
		
func handle_material():
	if(self.charge > 0):
		self.get_node("CSGMesh").mesh.material.albedo_color = onMat.albedo_color
		#print("updating material on")
	if(self.charge == 0):
		self.get_node("CSGMesh").mesh.material.albedo_color = offMat.albedo_color
		#print("updating material off")
		
func is_connected_to_source(depth = 0):
	return true
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var m = get_node("CSGMesh").mesh.duplicate(true)
	var mat = get_node("CSGMesh").mesh.surface_get_material(0).duplicate()
	get_node("CSGMesh").mesh = m
	get_node("CSGMesh").mesh.material = mat
	

func _on_Area_body_entered(body):
	if(body != self):
		set_charge(1)
func _on_Area_body_exited(body):
	if(body != self):
		set_charge(0)
