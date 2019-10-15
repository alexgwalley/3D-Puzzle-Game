extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var hovered_over = false

func _on_Area2D_area_entered(area):
	get_parent().hovered_over = true

func _on_Area2D_area_exited(area):
	get_parent().hovered_over = false