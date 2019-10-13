extends "res://Scripts/TestCube.gd"

#Connections
var inputConnection1 = null
var inputConnection1Path = ""
var inputConnection2 = null
var inputConnection2Path = ""
var charge = 0
var outputConnection = null
var outputConnectionPath = ""
var is_source = false
var updated = false

func _ready():
	var m = get_node("CSGMesh").mesh.duplicate(true)
	var mat = get_node("CSGMesh").mesh.surface_get_material(0).duplicate()
	get_node("CSGMesh").mesh = m
	get_node("CSGMesh").mesh.surface_set_material(0, mat)

func handle_connection(conn, connPath, parent=false) -> int:
	if(connection_exists(conn)):
		remove_connection(conn)
		return -1
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
func output_connection_exists(conn):
	if(outputConnection == conn):
		return true
	return false
func remove_connection(conn):
	if(inputConnection1 == conn):
		inputConnection1 = null
		inputConnection1Path = ""
	if(inputConnection2 == conn):
		inputConnection2 = null
		inputConnection2Path = ""
	if(outputConnection == conn):
		outputConnection = null
		outputConnectionPath = ""

func make_input_connection(conn, connPath) -> int:
	if(inputConnection1 == null):
		inputConnection1 = conn
		inputConnection1Path = connPath
		update_charge()
		return 1
	elif(inputConnection2 == null):
		inputConnection2 = conn
		inputConnection2Path = connPath
		update_charge()
		return 1
	
	return 0
	
func make_output_connection(conn, connPath) -> int:
	if(outputConnection == null):
		outputConnection = conn
		outputConnectionPath = connPath
		update_charge()
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
	
func is_connected_to_source(depth = 0):
	depth += 1
	if(depth > 50):
		return false
	if(inputConnection1 != null and inputConnection1.is_connected_to_source(depth)):
		return true
	if(inputConnection2 != null and inputConnection2.is_connected_to_source(depth)):
		return true
	
	return false

func set_charge(charge, depth=0):
	depth += 1
	if(depth > 50):
		return
	update_charge()
	pass_charge()

func pass_charge():
	if(outputConnection != null):
		outputConnection.set_charge(charge)
		outputConnection.pass_charge()

func update_charge(depth = 0):
	pass
	
func _process(delta):
	updated = false