extends Node

var saveDict

var playerPos
var playerParty
var playerMap
var playerNode

func _save():
	if playerNode == "":
		playerNode = get_node("/root/TestWorld/Player")
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	
	file.flush()
	
	saveDict = {
		playerPos = get_node("/root/TestWorld/Player").global_position,
		playerMap = get_tree().current_scene.scene_file_path,
		playerParty = get_node("/root/PlayerOwn").Party
	}
	
	file.store_var(saveDict)
	file = null
	
func _load():
	var file = FileAccess.open("user://save.dat", FileAccess.READ)
	if file == null:
		return
	saveDict = file.get_var()
	print(saveDict)
	if FileAccess.file_exists("user://save.dat"):
		call_deferred("playerSpot")

func playerSpot():
	get_node("/root/TestWorld/Player").global_position = saveDict["playerPos"]
	if playerParty != null:
		get_node("/root/PlayerOwn").Party = playerParty