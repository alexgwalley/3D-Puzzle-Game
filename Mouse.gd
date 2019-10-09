extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	var img = load("res://Images/White_Circle.png")
	var tex = ImageTexture.new()
	tex = tex.create_from_image(img)
	draw_texture(tex, Vector2(100, 100))

func _process(delta):
	update()
