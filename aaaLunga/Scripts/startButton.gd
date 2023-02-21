extends Button

var saveDict

func _on_button_down():
	var file = FileAccess.open("user://save.dat", FileAccess.READ)
	if FileAccess.file_exists("user://save.dat"):
		saveDict = file.get_var()
	#get_tree().change_scene_to_file("res://debug1.tscn")
	if FileAccess.file_exists("user://save.dat"):
		get_tree().change_scene_to_file(saveDict["playerMap"])
	else:
		get_tree().change_scene_to_file("res://debug1.tscn")
	get_node("/root/Save")._load()
