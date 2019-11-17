extends "res://Scripts/Gates/Gate.gd"

onready var mat
onready var light = get_node("SpotLight")
export var onCol : Color;
export var offCol : Color;

var type = 2

func _ready():
	var m = get_node("Spatial2/CSGMesh").mesh.duplicate(true)
	mat = get_node("Spatial2/CSGMesh").mesh.surface_get_material(0).duplicate()
	get_node("Spatial2/CSGMesh").mesh = m
	get_node("Spatial2/CSGMesh").mesh.surface_set_material(0, mat)
	mat.set_shader_param("albedo", onCol)
	mat.set_shader_param("emission", onCol)

func _process(delta):
	update_charge()
	
func update_charge(depth = 0, cts = null):
	depth += 1
	if(depth > 50):
		return
	updated = true
	lookedAt = true
	
	
	if(cts == null):
		if(inputConnection1 != null and inputConnection1.is_connected_to_source()):
			cts = true
		elif(inputConnection2 != null and inputConnection2.is_connected_to_source()):
			cts = true
		else:
			cts = false
	self.charge = 0
	
	if(inputConnection1 != null):
		self.charge = int(not inputConnection1.charge>0)
	else:
		self.charge = 1
		
	if(outputConnection != null and not outputConnection.updated):
		outputConnection.update_charge(depth, (charge>0))
	
	if(charge > 0):
		mat.set_shader_param("albedo", onCol)
		mat.set_shader_param("emission", onCol)
		light.light_color = onCol
	else:
		mat.set_shader_param("albedo", offCol)
		mat.set_shader_param("emission", offCol)
		light.light_color = offCol