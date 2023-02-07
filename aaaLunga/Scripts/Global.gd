extends Node

var playerLoc: Vector3

@onready var currentMap
@onready var lastMap
var saved_scene = null
var currentWild
var wildName
var playerMon = "Testagon2"
var playerName
@onready var playerGrid = Vector3(1, 2.7, 1)
@onready var enemyGrid = Vector3(4, 2.7, 4)

@onready var playersTurn = false
@onready var enemyTurn = false

@onready var MovePlayer = Vector3.ZERO
signal move_picked_player

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
	enemy = get_node("/root/mapBattle").monDict[currentWild] 
	var enemyMDL = load(get_node("/root/mapBattle").monDict[currentWild]["MODEL"]).instantiate()
	get_node("/root/mapBattle").add_child(enemyMDL)
	wildName = get_node("/root/mapBattle").monDict[currentWild]["NAME"]
	wildName = "/root/mapBattle/" + wildName
	get_node(wildName).position.x = (enemyGrid.x * 2.5) - 6.25
	get_node(wildName).position.y = 0.5
	get_node(wildName).position.z = (enemyGrid.z * 2.5) - 6.25
	
	#loads the player
	var player = get_node("/root/mapBattle").monDict[playerMon]
	var playerMDL = load(get_node("/root/mapBattle").monDict[playerMon]["MODEL"]).instantiate()
	get_node("/root/mapBattle").add_child(playerMDL)
	playerName = get_node("/root/mapBattle").monDict[playerMon]["NAME"]
	playerName = "/root/mapBattle/" + playerName
	get_node(playerName).position.x = (playerGrid.x * 2.5) - 6.25
	get_node(playerName).position.y = 0.5
	get_node(playerName).position.z = (playerGrid.z * 2.5) - 6.25
	
	#choose the first attacker
	if enemy["BSPEED"] > player["BSPEED"]:
		enemy_goes_first()
	else:
		player_goes_first()
		
		
func _unhandled_input(_event):
	if Input.is_action_just_pressed("left"):
		MovePlayer = Vector3(0, 0, -1)
		emit_signal("move_picked_player")
		_await_user()
	if Input.is_action_just_pressed("right"):
		MovePlayer = Vector3(0, 0, 1)
		emit_signal("move_picked_player")
		_await_user()
	if Input.is_action_just_pressed("forward"):
		MovePlayer = Vector3(1, 0, 0)
		emit_signal("move_picked_player")
		_await_user()
	if Input.is_action_just_pressed("back"):
		MovePlayer = Vector3(-1, 0, 0)
		emit_signal("move_picked_player")
		_await_user()
		
		
		
func _await_user():
	await self.move_picked_player
	return true
		
		
func enemy_goes_first():
	player_goes_first()
	
func player_goes_first():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var confirmed = await _await_user()
	if confirmed == true:
		playerGrid = playerGrid + MovePlayer
		get_node(playerName).position.x = (playerGrid.x * 2.5) - 6.25
		get_node(playerName).position.y = 0.5
		get_node(playerName).position.z = (playerGrid.z * 2.5) - 6.25
		enemy_goes_first()

