extends "res://Scripts/TestCube.gd"

var charge = 0
var outputConnection = null
var outputConnectionPath = ""

var is_source = false

#Materials
export var onColor:Color
export var offColor:Color

var updated = true
var lookedAt = false

var blockOnTop = false

onready var animator = get_node("CSGMesh/AnimationPlayer")

func set_charge(a: int, depth=0):
	depth += 1	
	if(depth > 50):
		return
		
	if(a <= 0):
		self.charge = 0
	else:
		self.charge = 1
	
	if(outputConnection != null):
		reset_checks()
		outputConnection.update_charge(0, charge>0)
		
	handle_material()
	
		
func connection_exists(conn):
	if(outputConnection == conn):
		return true
	return false
		
func output_connection_exists(conn):
	if(outputConnection == conn):
		return true
	return false
		
func handle_connection(conn, connPath, parent=true) -> int:
	if(conn == outputConnection):
		remove_connection(conn)
		return -1
	if(outputConnection != null or parent == false or conn.is_in_group("Purely Output")):
		return 0
	outputConnection = conn
	outputConnectionPath = connPath	
	reset_checks()
	outputConnection.update_charge(0, charge>0)
	return 1
	
func handle_connections_dead():
	if(not get_parent().get_parent().find_node("Wire Stuff").find_node("Wire Holders").has_node(outputConnectionPath) and
	   not get_parent().get_parent().find_node("Gates").has_node(outputConnectionPath)):
			remove_connection(outputConnection)
	
func remove_connection(conn):
	if(outputConnection == conn):
		outputConnection.update_charge()
		outputConnection = null
		outputConnectionPath = ""
		
		
func handle_material():
	if(self.charge > 0):
		self.get_node("CSGMesh").mesh.surface_get_material(0).albedo_color = onColor
		get_node("SpotLight").light_color = onColor
	if(self.charge == 0):
		self.get_node("CSGMesh").mesh.surface_get_material(0).albedo_color = offColor
		get_node("SpotLight").light_color = offColor
		
func is_connected_to_source(depth = 0):
	return charge>0
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var m = get_node("CSGMesh").mesh.duplicate(true)
	var mat = get_node("CSGMesh").mesh.surface_get_material(0).duplicate()
	get_node("CSGMesh").mesh = m
	get_node("CSGMesh").mesh.surface_set_material(0, mat)
	
func reset_checks():
	lookedAt = false
	if(outputConnection != null and outputConnection.lookedAt):
		outputConnection.reset_checks()
func reset_looked_at():
	reset_checks()
func _on_Area_body_entered(body):
	if(body != self):
		blockOnTop = true
		reset_checks()
		animator.play("ReleasedToPressed")
		set_charge(1)
func _on_Area_body_exited(body):
	if(body != self):
		blockOnTop = false
		reset_checks()
		animator.play("PressedToReleased")
		set_charge(0)
