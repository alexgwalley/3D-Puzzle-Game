extends "res://Scripts/TestCube.gd"

#Connections
var inputConnection1 = null
var inputConnection2 = null
var charge = 0
var outputConnection = null


func handle_connection(conn, connPath, parent=false) -> int:
	if(parent):
		return make_output_connection(conn)
	return make_input_connection(conn)

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

func make_input_connection(conn) -> int:
	if(inputConnection1 == null):
		inputConnection1 = conn
		return 1
	if(inputConnection2 == null):
		inputConnection2 = conn
		return 1

	return 0
func make_output_connection(conn) -> int:
	if(outputConnection == null):
		outputConnection = conn
		return 1
	return 0


func set_charge(caller, charge, depth):
	depth += 1
	if(depth > 50):
		return
	update_output()

func pass_charge():
	if(outputConnection != null):
		outputConnection.set_charge(self, charge)

func update_output():
	pass