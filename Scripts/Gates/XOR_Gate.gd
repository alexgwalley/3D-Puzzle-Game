extends "res://Scripts/Gates/Gate.gd"

onready var mat = get_node("Spatial2/CSGMesh").mesh.surface_get_material(0)
onready var light = get_node("SpotLight")
export var onCol : Color;
export var offCol : Color;

func _ready():
	mat.set_shader_param("albedo", offCol)
	mat.set_shader_param("emission", offCol)
	
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
	
	if(inputConnection1 != null and inputConnection2 != null):
		if( (inputConnection1.charge > 0 or inputConnection2.charge > 0) 
		and not (inputConnection1.charge > 0 and inputConnection2.charge > 0) ): # if either but not both
			self.charge = 1
			
	if(outputConnection != null and not outputConnection.updated):
		outputConnection.update_charge(depth, (cts and charge>0))
				
	if(charge > 0):
		mat.set_shader_param("albedo", onCol)
		mat.set_shader_param("emission", onCol)
		light.light_color = onCol
	else:
		mat.set_shader_param("albedo", offCol)
		mat.set_shader_param("emission", offCol)
		light.light_color = offCol