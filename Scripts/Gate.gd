extends "res://Scripts/TestCube.gd"

#Connections
var inputConnection1 = null
var inputConnection1Path = ""
var inputConnection2 = null
var inputConnection2Path = ""
var charge = 0
var outputConnection = null
var outputConnectionPath = ""

func _ready():
	var m = get_node("CSGMesh").mesh.duplicate(true)
	var mat = get_node("CSGMesh").mesh.surface_get_material(0).duplicate()
	get_node("CSGMesh").mesh = m
	get_node("CSGMesh").mesh.surface_set_material(0, mat)

func handle_connection(conn, connPath, parent=false) -> int:
	if(connection_exists(conn)):
		remove_connection(conn)
	if(parent):
		return make_output_connection(conn, connPath)
	return make_input_connection(conn, connPath)

func connection_exists(conn):
	if(inputConnection1 == conn):
		return true
	if(inputConnection2 == conn):
		return true
	if(outputConnection == conn):
		return true

	return false
func remove_connection(conn):
	if(inputConnection1 == conn):
		inputConnection1 = null
	if(inputConnection2 == conn):
		inputConnection2 = null
	if(outputConnection == conn):
		outputConnection = null

func make_input_connection(conn, connPath) -> int:
	if(inputConnection1 == null):
		inputConnection1 = conn
		inputConnection1Path = connPath
		return 1
	if(inputConnection2 == null):
		inputConnection2 = conn
		inputConnection2Path = connPath
		return 1

	return 0
func make_output_connection(conn, connPath) -> int:
	if(outputConnection == null):
		outputConnection = conn
		outputConnectionPath = connPath
		return 1
	return 0

func handle_connections_dead():
	if(not get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(outputConnectionPath) and
	   not get_parent().get_parent().find_node("Gates").has_node(outputConnectionPath)):
			outputConnection = null
	if(not get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(inputConnection1Path) and
	   not get_parent().get_parent().find_node("Gates").has_node(inputConnection1Path)):
			inputConnection1 = null
	if(not get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(inputConnection2Path) and
	   not get_parent().get_parent().find_node("Gates").has_node(inputConnection2Path)):
			inputConnection2 = null
	

func set_charge(caller, charge, depth=0):
	depth += 1
	if(depth > 50):
		return
	update_output()
	pass_charge()

func pass_charge():
	if(outputConnection != null):
		outputConnection.set_charge(self, charge)

func update_output():
	pass