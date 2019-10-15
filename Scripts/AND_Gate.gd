extends "res://Scripts/Gate.gd"

onready var mat = get_node("CSGMesh").mesh.surface_get_material(0)
onready var light = get_node("SpotLight")
export var onCol : Color;
export var offCol : Color;

func _ready():
	mat.set_shader_param("albedo", offCol)
	mat.set_shader_param("emission", offCol)
func _process(delta):
	update_charge()
	
func update_charge(depth = 0, cts = false):
	depth += 1
	if(depth > 50):
		return
	
	updated = true
	lookedAt = true
	self.charge = 0

	if(inputConnection1 != null and inputConnection2 != null):
		if(inputConnection1.charge > 0 and inputConnection2.charge > 0):
			self.charge = 1
			
	if(outputConnection != null and not outputConnection.updated):
		outputConnection.update_charge(depth, cts)
				
	if(charge > 0):
		mat.set_shader_param("albedo", onCol)
		mat.set_shader_param("emission", onCol)
		light.light_color = onCol
	else:
		mat.set_shader_param("albedo", offCol)
		mat.set_shader_param("emission", offCol)
		light.light_color = offCol