extends Control

export var fontColor: Color
# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.add_color_override("font_color", fontColor)

func updateModeGUI():
	if(Singleton.gameMode == Singleton.MAP_MODE):
		$Label.text = "MAP"
	elif(Singleton.gameMode == Singleton.BUILD_MODE):
		$Label.text = "BUILD"
	elif(Singleton.gameMode == Singleton.WIRE_MODE):
		$Label.text = "WIRE"
	elif(Singleton.gameMode == Singleton.INTERACT_MODE):
		$Label.text = "INTERACT"
	elif(Singleton.gameMode == Singleton.CHECKING_MODE):
		$Label.text = "CHECKING..."

