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
var can_take_charges = true
var charge
var mat
var is_source = false
var updated = false
var lookedAt = false

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
		return 0
	if(connection_exists(conn)):
		self.remove_connection(conn)
		return -1
	else:
		return int(add_connection(conn, connPath))

func connection_exists(conn):
	if((connection1 != null and connection1 == conn) or
	   (connection2 != null and connection2 == conn) or
	   (connection3 != null and connection3 == conn) or
	   (connection4 != null and connection4 == conn)):
		return true		
	return false

func output_connection_exists(conn):
	if((connection1 != null and connection1 == conn) or
	   (connection2 != null and connection2 == conn) or
	   (connection3 != null and connection3 == conn) or
	   (connection4 != null and connection4 == conn)):
		return true		
	return false

func handle_connections_dead():
	if(not get_parent().get_parent().get_parent().find_node("Gates").has_node(connection1Path) and
	   not get_parent().get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(connection1Path)):
		remove_connection(connection1)
	if(not get_parent().get_parent().get_parent().find_node("Gates").has_node(connection2Path) and
	   not get_parent().get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(connection2Path)):
		remove_connection(connection2)
	if(not get_parent().get_parent().get_parent().find_node("Gates").has_node(connection3Path) and
	   not get_parent().get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(connection3Path)):
		remove_connection(connection3)
	if(not get_parent().get_parent().get_parent().find_node("Gates").has_node(connection4Path) and
	   not get_parent().get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(connection4Path)):
		remove_connection(connection4) 

func print_connections():
	print(str(self) + "has connections of: ")
	print(connection1)
	print(connection2)
	print(connection3)
	print(connection4)

func add_connection(conn, connPath) -> bool:
	#print("Added connection")
	if(number_of_connections + 1 > max_connections):
		return false 
	number_of_connections += 1
	if(connection1 == null):
		connection1 = conn
		connection1Path = connPath
	elif(connection2 == null):
		connection2 = conn
		connection2Path = connPath
	elif(connection3 == null):
		connection3 = conn
		connection3Path = connPath
	elif(connection4 == null):
		connection4 = conn
		connection4Path = connPath
	reset_looked_at()
	update_charge()
	return true

func reset_looked_at():
	lookedAt = false
	if(connection1 != null and connection1.lookedAt):
		connection1.reset_looked_at()	
	if(connection2 != null and connection2.lookedAt):
		connection2.reset_looked_at()	
	if(connection3 != null and connection3.lookedAt):
		connection3.reset_looked_at()	
	if(connection4 != null and connection4.lookedAt):
		connection4.reset_looked_at()	

func remove_connection(conn):
	var removed = false
	if(conn == connection1):
		connection1 = null
		connection1Path = ""
		removed = true
	if(conn == connection2):
		connection2 = null
		connection2Path = ""
		removed = true
	if(conn == connection3):
		connection3 = null
		connection3Path = ""
		removed = true
	if(conn == connection4):
		connection4 = null
		connection4Path = ""
		removed = true
		
	if(removed):
		#print_connections()
		reset_looked_at()
		self.update_charge()
		number_of_connections -= 1
		
func is_connected_to_source(depth = 0):
	depth += 1
	if(depth > 50):
		return false
	
	if(is_source == true and charge > 0): #this should never happen, but it might  :0
		return true
	lookedAt = true	
	if(connection1 != null and not connection1.lookedAt and connection1.is_connected_to_source(depth)):
		return true
	if(connection2 != null and not connection2.lookedAt and connection2.is_connected_to_source(depth)):
		return true
	if(connection3 != null and not connection3.lookedAt and connection3.is_connected_to_source(depth)):
		return true
	if(connection4 != null and not connection4.lookedAt and connection4.is_connected_to_source(depth)):
		return true
	return false
	
func update_charge(depth = 0):
	depth += 1
	if(depth > 50):
		return false
	self.charge = 0
	#print_debug("updating_charge")
	if(connection1 != null and connection1.charge > 0 and connection1.output_connection_exists(self) and connection1.is_connected_to_source()):
		self.charge = 1
	elif(connection2 != null and connection2.charge > 0 and connection2.output_connection_exists(self) and connection2.is_connected_to_source()):
		self.charge = 1
	elif(connection3 != null and connection3.charge > 0 and connection3.output_connection_exists(self) and connection3.is_connected_to_source()):
		self.charge = 1
	elif(connection4 != null and connection4.charge > 0 and connection4.output_connection_exists(self) and connection4.is_connected_to_source()):
		self.charge = 1
	updated = true
	if(connection1 != null and not connection1.updated and not connection1.is_in_group("Purely Output")):
		connection1.update_charge(depth)
		#print(name + " is updating " + connection1.name + "'s charge")
	if(connection2 != null and not connection2.updated and not connection2.is_in_group("Purely Output")):
		connection2.update_charge(depth)
		#print(name + " is updating " + connection2.name + "'s charge")
	if(connection3 != null and not connection3.updated and not connection3.is_in_group("Purely Output")):
		connection3.update_charge(depth)
		#print(name + " is updating " + connection3.name + "'s charge")
	if(connection4 != null and not connection4.updated and not connection4.is_in_group("Purely Output")):
		connection4.update_charge(depth)
		#print(name + " is updating " + connection4.name + "'s charge")

func set_charge(c):
	self.charge = c

func pass_charge(depth=0):
	depth += 1
	if(depth > 30):
		return
	if(connection1 != null and self.charge != connection1.charge):
		connection1.set_charge(self.charge)
		connection1.pass_charge()
	if(connection2 != null and self.charge != connection2.charge):
		connection2.set_charge(self.charge)
		connection2.pass_charge()
	if(connection3 != null and self.charge != connection3.charge):
		connection3.set_charge(self.charge)
		connection3.pass_charge()
	if(connection4 != null and self.charge != connection4.charge):
		connection4.set_charge(self.charge)
		connection4.pass_charge()

func handle_material():
	if(self.charge > 0):
		get_node("Mesh").mesh.material.albedo_color = Color(1, 1, 0, 1)
	if(self.charge == 0):
		get_node("Mesh").mesh.material.albedo_color = Color(0, 0, 0, 1)
		
func _process(delta):
	updated = false
	handle_material()