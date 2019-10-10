extends "res://Scripts/Gate.gd"

func update_output():
	if(inputConnection1 != null and inputConnection2 != null):
		if(inputConnection1.charge == 1 or inputConnection2.charge == 1 and inputConnection1 != inputConnection2):
			charge = 1
		else:
			charge = 0
	pass_charge()
