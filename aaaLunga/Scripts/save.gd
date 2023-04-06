extends Node

var saveDict

var scene
var sceneitem

var playerPos
var playerParty
var playerMap
var playerNode

func _save():
	if playerNode == "":
		playerNode = get_node("/root/TestWorld/Player")
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	var saveScene = PackedScene.new()
	var itemScene = PackedScene.new()
	file.flush()
	
	saveDict = {
		playerPos = get_node("/root/TestWorld/Player").global_position,
		playerMap = get_tree().current_scene.scene_file_path,
	}
	var party = Node.new()
	for i in get_node("/root/PlayerParty").pokemon:
		var j = i.duplicate()
		party.add_child(j)
		j.owner = party
	saveScene.pack(party)
	var items = Node.new()
	for k in get_node("/root/PlayerItems").items:
		var l = k.duplicate()
		items.add_child(l)
		l.owner = items
	itemScene.pack(items)
	ResourceSaver.save(saveScene, "user://party.tscn")
	ResourceSaver.save(itemScene, "user://items.tscn")

	file.store_var(saveDict)
	file = null
	
func _load():
	if FileAccess.file_exists("user://party.tscn"):
		scene = ResourceLoader.load("user://party.tscn").instantiate()
	if FileAccess.file_exists("user://items.tscn"):
		sceneitem = ResourceLoader.load("user://items.tscn").instantiate()
	var file = FileAccess.open("user://save.dat", FileAccess.READ)
	if file == null:
		return
	saveDict = file.get_var()
	if FileAccess.file_exists("user://save.dat"):
		call_deferred("playerSpot")

func playerSpot():
	get_node("/root/TestWorld/Player").global_position = saveDict["playerPos"]
	for i in scene.get_children():
		var j = i.duplicate()
		get_node("/root/PlayerParty").add_pokemon(j)
	for k in sceneitem.get_children():
		var l = k.duplicate()
		get_node("/root/PlayerItems").add_item(l)
