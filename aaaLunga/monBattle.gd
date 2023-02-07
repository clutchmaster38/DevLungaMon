extends Node3D


#THE CREATURE DICTIONARY. 
@onready var monDict = {
	"Testagon" = {
		"MODEL" : "res://mon/test1.glb",
		"NAME" : "/test1",
		"BHP" : 35,
		"BATTACK" : 55,
		"BDEFENSE" : 30,
		"BSPAT" : 50,
		"BSPDF" : 50,
		"BSPEED" : 90
		},
	"Testagon2" = {
		"MODEL" : "res://mon/test2.glb",
		"NAME" : "/test2",
		"BHP" : 80,
		"BATTACK" : 110,
		"BDEFENSE" : 130,
		"BSPAT" : 55,
		"BSPDF" : 65,
		"BSPEED" : 45
		}
}



#BATTLE LOGIC
func _ready():
	get_node("/root/Global").start_battle()

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		get_node("/root/Global").end_battle()


