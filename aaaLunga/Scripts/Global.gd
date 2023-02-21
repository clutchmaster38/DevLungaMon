extends Node

var playerLoc: Vector3

@onready var currentMap
@onready var lastMap
@onready var inBattle = false
var saved_scene = null
var currentWild
var wildName
var playerMon
var playerName
@onready var playerGrid = Vector3(1, 2.7, 1)
@onready var enemyGrid = Vector3(4, 2.7, 4)

@onready var playersTurn = false
@onready var enemyTurn = false


var wildHP
var wildLevel
var wildAttack
var wildDefense
var wildMoves

var enemyPower

var playerHP
var playerLevel
var playerAttack
var playerDefense
var playerPower

@onready var MovePlayer = Vector3.ZERO

var MoveVec
var AttVec

signal move_picked_player
@onready var movePickedNumber

var enemy
@onready var spawnNode
var playerTurn

@onready var battlescene = preload("res://battle.tscn").instantiate()
@onready var overworld


#switchs to battle
func switch_scene():
	overworld = get_node("/root/TestWorld")
	get_node("/root").remove_child(overworld)
	get_node("/root").add_child(battlescene)
	
func end_battle():
	overworld.remove_child(spawnNode)
	battlescene.free()
	get_node("/root").add_child(overworld)
	get_tree().set_current_scene(overworld)
	battlescene = preload("res://battle.tscn").instantiate()
	
#loads the right creature
func load_wild_creature():
	currentWild = spawnNode.creatureName
	wildLevel = spawnNode.creatureLevel
	wildMoves = spawnNode.creatureMoves
	
#inits the battle
func start_battle():
	#load enemy
	inBattle = true
	enemy = get_node("/root/mapBattle").monDict[currentWild] 
	var enemyMDL = load(get_node("/root/mapBattle").monDict[currentWild]["MODEL"]).instantiate()
	get_node("/root/mapBattle").add_child(enemyMDL)
	wildName = get_node("/root/mapBattle").monDict[currentWild]["NAME"]
	wildName = "/root/mapBattle/" + wildName
	
	enemyGrid = Vector3(4, 2.7, 4)
	get_node(wildName).position.x = (enemyGrid.x * 2.5) - 6.25
	get_node(wildName).position.y = 0.5
	get_node(wildName).position.z = (enemyGrid.z * 2.5) - 6.25
	
	var wildBHP = get_node("/root/mapBattle").monDict[currentWild]["BHP"]
	wildAttack = get_node("/root/mapBattle").monDict[currentWild]["BATTACK"]
	wildDefense = get_node("/root/mapBattle").monDict[currentWild]["BDEFENSE"]
	
	wildHP = floor(0.01 * (2 * wildBHP + 14 + floor(0.25 * 60)) * wildLevel) + wildLevel + 10
	
	get_node("/root/mapBattle/NME/EnemyHealth").text = str(wildHP)
	get_node("/root/mapBattle/GUI/PlayerHealth").text = str(playerHP)
	
	#loads the player
	playerMon = get_node("/root/PlayerOwn").Party["creature1"]["creatureName"]
	playerLevel = get_node("/root/PlayerOwn").Party["creature1"]["creatureLevel"]
	var player = get_node("/root/mapBattle").monDict[playerMon]
	var playerMDL = load(get_node("/root/mapBattle").monDict[playerMon]["MODEL"]).instantiate()
	get_node("/root/mapBattle").add_child(playerMDL)
	playerName = get_node("/root/mapBattle").monDict[playerMon]["NAME"]
	playerName = "/root/mapBattle/" + playerName
	
	var playerBHP = get_node("/root/mapBattle").monDict[playerMon]["BHP"]
	
	playerHP = floor(0.01 * (2 * playerBHP + 14 + floor(0.25 * 60)) * playerLevel) + playerLevel + 10
	
	playerAttack = get_node("/root/mapBattle").monDict[playerMon]["BATTACK"]
	playerDefense = get_node("/root/mapBattle").monDict[playerMon]["BDEFENSE"]
	
	playerGrid = Vector3(1, 2.7, 1)
	get_node(playerName).position.x = (playerGrid.x * 2.5) - 6.25
	get_node(playerName).position.y = 0.5
	get_node(playerName).position.z = (playerGrid.z * 2.5) - 6.25
	
	
	
	#choose the first attacker
	if enemy["BSPEED"] > player["BSPEED"]:
		enemy_goes_first()
	else:
		player_goes_first()
		
		
func _unhandled_input(_event):
	if inBattle == true && playerTurn == true:
		if Input.is_action_just_pressed("left"):
			MoveVec = get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move2"]]["Distance"]
			MovePlayer = Vector3(0, 0, -MoveVec)
			movePickedNumber = "move2"
			AttVec = Vector3(0, 0, -get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"][movePickedNumber]]["AttVector"])
			
			emit_signal("move_picked_player")
			_await_user()
		if Input.is_action_just_pressed("right"):
			MoveVec = get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move3"]]["Distance"]
			MovePlayer = Vector3(0, 0, MoveVec)
			movePickedNumber = "move3"
			AttVec = Vector3(0, 0, get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"][movePickedNumber]]["AttVector"])
			
			emit_signal("move_picked_player")
			_await_user()
		if Input.is_action_just_pressed("forward"):
			MoveVec = get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move1"]]["Distance"]
			MovePlayer = Vector3(MoveVec, 0, 0)
			movePickedNumber = "move1"
			AttVec = Vector3(get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"][movePickedNumber]]["AttVector"], 0, 0)
			
			emit_signal("move_picked_player")
			_await_user()
		if Input.is_action_just_pressed("back"):
			MoveVec = get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move4"]]["Distance"]
			MovePlayer = Vector3(-MoveVec, 0, 0)
			movePickedNumber = "move4"
			AttVec = Vector3(-get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"][movePickedNumber]]["AttVector"], 0, 0)
			
			emit_signal("move_picked_player")
			_await_user()
		
		
		
func _await_user():
	await self.move_picked_player
	return true
		
		
func enemy_goes_first():
	var enemyMove = randf_range(1, 5)
	var enemyMoveVec
	var enemyAttVec
	enemyMove = int(enemyMove)
	var moveEnemy
	print(enemyMove)
	match enemyMove:
		1:
			enemyMoveVec = get_node("/root/MoveDex").MoveDex[wildMoves["move1"]]["Distance"]
			moveEnemy = Vector3(0, 0, -enemyMoveVec)
			enemyAttVec = Vector3(0, 0, -get_node("/root/MoveDex").MoveDex[wildMoves["move1"]]["AttVector"])
			enemyPower = get_node("/root/MoveDex").MoveDex[wildMoves["move1"]]["Power"]
		2:
			enemyMoveVec = get_node("/root/MoveDex").MoveDex[wildMoves["move2"]]["Distance"]
			moveEnemy = Vector3(0, 0, enemyMoveVec)
			enemyAttVec = Vector3(0, 0, get_node("/root/MoveDex").MoveDex[wildMoves["move2"]]["AttVector"])
			enemyPower = get_node("/root/MoveDex").MoveDex[wildMoves["move2"]]["Power"]
		3:
			enemyMoveVec = get_node("/root/MoveDex").MoveDex[wildMoves["move3"]]["Distance"]
			moveEnemy = Vector3(enemyMoveVec, 0, 0)
			enemyAttVec = Vector3(get_node("/root/MoveDex").MoveDex[wildMoves["move3"]]["AttVector"], 0, 0)
			enemyPower = get_node("/root/MoveDex").MoveDex[wildMoves["move3"]]["Power"]
		4:
			enemyMoveVec = get_node("/root/MoveDex").MoveDex[wildMoves["move4"]]["Distance"]
			moveEnemy = Vector3(-enemyMoveVec, 0, 0)
			enemyAttVec = Vector3(-get_node("/root/MoveDex").MoveDex[wildMoves["move4"]]["AttVector"], 0, 0)
			
	enemyGrid = enemyGrid + moveEnemy
	if enemyGrid == playerGrid:
		enemyGrid = enemyGrid - moveEnemy
	enemyGrid.x = clamp(enemyGrid.x, 1, 4)
	enemyGrid.z = clamp(enemyGrid.z, 1, 4)
	if playerGrid == enemyGrid + enemyAttVec:
		playerHP -= ((((2 * wildLevel * 1) / 5) * enemyPower * (wildAttack / playerDefense)) / 50) + 2
	get_node(wildName).position.x = (enemyGrid.x * 2.5) - 6.25
	get_node(wildName).position.y = 0.5
	get_node(wildName).position.z = (enemyGrid.z * 2.5) - 6.25
	get_node("/root/mapBattle/NME/EnemyHealth").text = str(wildHP)
	get_node("/root/mapBattle/GUI/PlayerHealth").text = str(playerHP)
	player_goes_first()
	
func player_goes_first():
	playerTurn = true
	var confirmed = await _await_user()
	if confirmed == true:
		playerPower = get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"][movePickedNumber]]["Power"]
		playerGrid = playerGrid + MovePlayer
		if playerGrid == enemyGrid:
			playerGrid = playerGrid - MovePlayer
			
		if enemyGrid == playerGrid + AttVec:
			wildHP -= ((((2 * playerLevel * 1) / 5) * playerPower * (playerAttack / wildDefense)) / 50) + 2
		playerGrid.x = clamp(playerGrid.x, 1, 4)
		playerGrid.z = clamp(playerGrid.z, 1, 4)
		get_node(playerName).position.x = (playerGrid.x * 2.5) - 6.25
		get_node(playerName).position.y = 0.5
		get_node(playerName).position.z = (playerGrid.z * 2.5) - 6.25
		get_node("/root/mapBattle/NME/EnemyHealth").text = str(wildHP)
		get_node("/root/mapBattle/GUI/PlayerHealth").text = str(playerHP)
		playerTurn = false
		if wildHP <= 0:
			end_battle()
			_check_level()
			return
		enemy_goes_first()

func _check_level():
	var newEXP = get_node("/root/PlayerOwn").Party["creature1"]["creatureExp"] + (wildLevel * 13)
	get_node("/root/PlayerOwn").Party["creature1"]["creatureExp"] = newEXP
	get_node("/root/PlayerOwn").Party["creature1"]["creatureLevel"] = floor(pow(newEXP, 1/3.0))
	print(get_node("/root/PlayerOwn").Party["creature1"]["creatureExp"])
	print(get_node("/root/PlayerOwn").Party["creature1"]["creatureLevel"])
