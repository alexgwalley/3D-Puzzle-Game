extends "res://Scripts/Gate.gd"

func update_output():
	if(inputConnection1 != null and inputConnection2 != null):
		if(inputConnection1.charge > 0 or inputConnection2.charge > 0 and not (inputConnection1.charge > 0 and inputConnection2.charge > 0)):
			charge = 1
		else:
			charge = 0
		pass_charge()
