extends Node

var playerLoc: Vector3

@onready var currentMap
@onready var lastMap
var saved_scene = null
var currentWild
var wildName
var playerMon = "Testagon2"
var playerName

var enemy
@onready var spawnNode

@onready var battlescene = preload("res://battle.tscn").instantiate()
@onready var overworld

#switchs to battle
func switch_scene():
	overworld = get_node("/root/TestWorld")
	get_node("/root").remove_child(get_node("/root/TestWorld"))
	get_node("/root").add_child(battlescene)
	
func end_battle():
	overworld.remove_child(spawnNode)
	battlescene.queue_free()
	get_node("/root").add_child(overworld)
	
#loads the right creature
func load_wild_creature():
	currentWild = spawnNode.creatureName
	
#inits the battle
func start_battle():
	#load enemy
	var enemy = get_node("/root/mapBattle").monDict[currentWild] 
	var enemyMDL = load(get_node("/root/mapBattle").monDict[currentWild]["MODEL"]).instantiate()
	get_node("/root/mapBattle").add_child(enemyMDL)
	wildName = get_node("/root/mapBattle").monDict[currentWild]["NAME"]
	wildName = "/root/mapBattle/" + wildName
	get_node(wildName).position = Vector3(3.75, .5, 3.75)
	
	#loads the player
	var player = get_node("/root/mapBattle").monDict[playerMon]
	var playerMDL = load(get_node("/root/mapBattle").monDict[playerMon]["MODEL"]).instantiate()
	get_node("/root/mapBattle").add_child(playerMDL)
	playerName = get_node("/root/mapBattle").monDict[playerMon]["NAME"]
	playerName = "/root/mapBattle/" + playerName
	get_node(playerName).position = Vector3(-3.75, .5, -3.75)
	
	#choose the first attacker
	if enemy["BSPEED"] > player["BSPEED"]:
		enemy_goes_first()
	else:
		player_goes_first()
		
		
func enemy_goes_first():
	print("ENEMY")
	
func player_goes_first():
	print("PLAYER")
	
