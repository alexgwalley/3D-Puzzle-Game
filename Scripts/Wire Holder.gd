extends "res://Scripts/TestCube.gd"

var parent = null
var connection1 = null
var connection1Path = ""
var connection2 = null
var connection2Path = ""
var connection3 = null
var connection3Path = ""
var connection4 = null
var connection4Path = ""
var number_of_connections = 0
var max_connections = 4
var charge
var mat

var onMat = load("res://Materials/wire_on_material.tres")
var offMat = load("res://Materials/wire_off_material.tres")

func _ready():
	self.charge = 0
	var m = get_node("Mesh").mesh.duplicate(true)
	var mat = get_node("Mesh").mesh.surface_get_material(0).duplicate()
	get_node("Mesh").mesh = m
	get_node("Mesh").mesh.material = mat
	
func handle_connection(conn, connPath, parent=false) -> int:
	if(conn == self):
		return 1
	if(connection_exists(conn)):
		remove_connection(conn)
		return -1
	else:
		return int(add_connection(conn, connPath))
		

func connection_exists(conn):
	if(connection1 == conn or
	   connection2 == conn or
	   connection3 == conn or
	   connection4 == conn):
		return true
	return false

func handle_connections_dead():
	if(not get_parent().get_parent().get_parent().find_node("Gates").has_node(connection1Path) and
	   not get_parent().get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(connection4Path)):
		remove_connection(connection1)
		print("removed connection")
	if(not get_parent().get_parent().get_parent().find_node("Gates").has_node(connection2Path) and
	   not get_parent().get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(connection4Path)):
		remove_connection(connection2)
		print("removed connection")
	if(not get_parent().get_parent().get_parent().find_node("Gates").has_node(connection3Path) and
	   not get_parent().get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(connection4Path)):
		remove_connection(connection3)
		print("removed connection")
	if(not get_parent().get_parent().get_parent().find_node("Gates").has_node(connection4Path) and
	   not get_parent().get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(connection4Path)):
		remove_connection(connection4)
		print("removed connection")

func add_connection(conn, connPath) -> bool:
	if(number_of_connections + 1 > max_connections):
		return false 
	number_of_connections += 1
	if(number_of_connections == 1):
		connection1 = conn
		connection1Path = connPath
	if(number_of_connections == 2):
		connection2 = conn
		connection2Path = connPath
	if(number_of_connections == 3):
		connection3 = conn
		connection3Path = connPath
	if(number_of_connections == 4):
		connection4 = conn
		connection4Path = connPath
	return true
	
func remove_connection(conn):
	if(conn == connection1):
		connection1 = null
		connection1Path = ""
		number_of_connections -= 1
	if(conn == connection2):
		connection2 = null
		connection2Path = ""
		number_of_connections -= 1
	if(conn == connection3):
		connection3 = null
		connection3Path = ""
		number_of_connections -= 1
	if(conn == connection4):
		connection4 = null
		connection4Path = ""
		number_of_connections -= 1
	

func set_charge(caller, c:int, depth=0):
	depth += 1
	print(depth)
	if(depth > 10):
		return
	#Look for a loop ===========================
	self.charge = c
	#print("recieved charge %d " % self.charge)

	if(connection1 != null and connection1 != caller):
		connection1.set_charge(self, c, depth)
	if(connection2 != null and connection2 != caller):
		connection2.set_charge(self, c, depth)
	if(connection3 != null and connection3 != caller):
		connection3.set_charge(self, c, depth)
	if(connection4 != null and connection4 != caller):
		connection4.set_charge(self, c, depth)

func handle_material():
	if(self.charge == 1):
		get_node("Mesh").mesh.material.albedo_color = Color(1, 1, 0, 1)
	if(self.charge == 0):
		get_node("Mesh").mesh.material.albedo_color = Color(0, 0, 0, 1)
		
func _process(delta):
	handle_material()