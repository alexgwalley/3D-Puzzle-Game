extends StaticBody

onready var mat = load("res://Materials/Floor.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	mat.set_shader_param("global_transform", get_global_transform())
