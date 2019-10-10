extends "res://Scripts/Gate.gd"

onready var mat = get_node("CSGMesh").mesh.surface_get_material(0)
onready var light = get_node("light")
export var onCol : Color;
export var offCol : Color;


func _ready():
	mat.set_shader_param("albedo", offCol)
	mat.set_shader_param("emission", offCol)

func update_output():
	if(inputConnection1 != null and inputConnection2 != null):
		if(inputConnection1.charge == 1 or inputConnection2.charge == 1):
			charge = 1
			mat.set_shader_param("albedo", onCol)
			mat.set_shader_param("emission", onCol)
			light.light_color = onCol
		else:
			charge = 0
			mat.set_shader_param("albedo", offCol)
			mat.set_shader_param("emission", offCol)
			light.light_color = offCol
	pass_charge()
