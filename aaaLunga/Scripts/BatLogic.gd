extends Node

#inits the battle scene
@onready var battlescene = preload("res://battle.tscn").instantiate()
@onready var spawnNode
var overworld
var inBattle = false

var GridSquared = 4

var attackingSpot

var playerTurn
var playerChooseToMove = false
var movePicked

signal MOVE_PICKED

var partyPos = "creature1"

#important Variables for the player
var playerName
var player
var playerGridPosition
var playerBHP
var playerHP
var playerLevel
var playerAttack
var playerDefense
var playerSpeed
var playerMoves
var playerAttVec
var playerFacing = "forward"
var playerMoveChosen

#Important Variables for the enemy
var enemyName
var enemy
var enemyGridPosition
var enemyBHP
var enemyHP
var enemyLevel
var enemyAttack
var enemyDefense
var enemySpeed
var enemyMoves
var enemyAttVec
var enemyMovePick
var enemyFacing

func start_battle(creatureName, creatureLevel, _creatureNature, move1, move2, move3, move4):
	
	inBattle = true
	#scene transition
	overworld = get_node("/root/TestWorld")
	get_node("/root").remove_child(overworld)
	get_node("/root").add_child(battlescene)
	
	#load enemy Pokemon
	enemyName = creatureName
	enemy = load_creature(creatureName)
	enemyGridPosition = Vector3(4, 0, 4)
	await move_on_grid(enemy, enemyGridPosition, 0)
	
	enemyBHP = get_node("/root/mapBattle").monDict[creatureName]["BHP"]
	enemyLevel = creatureLevel
	enemyHP = calc_HP(enemyBHP, creatureLevel)
	enemyAttack = calc_stats(get_node("/root/mapBattle").monDict[creatureName]["BATTACK"], enemyLevel)
	enemyDefense = calc_stats(get_node("/root/mapBattle").monDict[creatureName]["BDEFENSE"], enemyLevel)
	enemyMoves = {
		"move1" = move1,
		"move2" = move2,
		"move3" = move3,
		"move4" = move4
	}
	
	get_node("/root/mapBattle/NME/EnemyHealth").text = str(enemyHP)
	
	#load player Pokemon
	playerName = get_node("/root/PlayerOwn").Party["creature1"]["creatureName"]
	player = load_creature(playerName)
	playerGridPosition = Vector3(1, 0, 1)
	await move_on_grid(player, playerGridPosition, 0)
	
	playerBHP = get_node("/root/mapBattle").monDict[playerName]["BHP"]
	playerLevel = get_node("/root/PlayerOwn").Party["creature1"]["creatureLevel"]
	playerHP = calc_HP(playerBHP, playerLevel)
	playerAttack = calc_stats(get_node("/root/mapBattle").monDict[playerName]["BATTACK"], playerLevel)
	playerDefense = calc_stats(get_node("/root/mapBattle").monDict[playerName]["BDEFENSE"], playerLevel)
	
	get_node("/root/mapBattle/GUI/PlayerHealth").text = str(playerHP)
	
	get_node("/root/mapBattle/joyPad/Top").text = get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move1"]
	get_node("/root/mapBattle/joyPad/Bottom").text = get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move4"]
	get_node("/root/mapBattle/joyPad/Left").text = get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move2"]
	get_node("/root/mapBattle/joyPad/Right").text = get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move3"]
	
	playerMoves = {
		"move1" = get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move1"],
		"move2" = get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move2"],
		"move3" = get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move3"],
		"move4" = get_node("/root/PlayerOwn").Party["creature1"]["creatureMoves"]["move4"]
	}
	
	playerSpeed = calc_stats(get_node("/root/mapBattle").monDict[playerName]["BSPEED"], playerLevel)
	enemySpeed = calc_stats(get_node("/root/mapBattle").monDict[creatureName]["BSPEED"], enemyLevel)
	
	if playerSpeed > enemySpeed:
		call_deferred("player_turn")
		return
	else:
		call_deferred("enemy_turn")
		return

func player_turn():
	movePicked = false
	playerTurn = true
	await MOVE_PICKED
	get_node("/root/mapBattle/GUI/PlayerHealth").text = str(playerHP)
	get_node("/root/mapBattle/NME/EnemyHealth").text = str(enemyHP)
	if enemyHP <= 0:
		call_deferred("end_battle")
		return
	if playerHP <= 0:
		call_deferred("end_battle")
		return
	enemy_turn()

func enemy_turn():
	var enemyMove
	await get_tree().create_timer(0.1).timeout
	if playerGridPosition.x > enemyGridPosition.x:
		enemyMove = 1
	elif playerGridPosition.x < enemyGridPosition.x:
		enemyMove = 2
	elif playerGridPosition.z > enemyGridPosition.z:
		enemyMove = 3
	else:
		enemyMove = 4
	
	match enemyMove:
		1:
			enemyGridPosition.x = enemyGridPosition.x + 1
			if enemyGridPosition.x == 5:
				enemyGridPosition.x = 3
				enemy.look_at(enemy.position + Vector3(0, 0, 1), Vector3.UP)
			else:
				enemy.look_at(enemy.position + Vector3(0, 0, -1), Vector3.UP)
			if enemyGridPosition == playerGridPosition:
				enemyGridPosition.x = enemyGridPosition.x - 1
				enemyFacing = "back"
				enemyMovePick = int(randf_range(1,5))
				enemyMovePick = "move" + str(enemyMovePick)
				enemyMovePick = enemyMoves[enemyMovePick]
				await hit_test(get_node("/root/MoveDex").MoveDex[enemyMovePick]["AttVector"], get_node("/root/MoveDex").MoveDex[enemyMovePick]["Power"], enemy, enemyFacing)
			await move_on_grid(enemy, enemyGridPosition, 0.08)
		2:
			enemyGridPosition.x = enemyGridPosition.x - 1
			if enemyGridPosition.x == 0:
				enemyGridPosition.x = 2
				enemy.look_at(enemy.position + Vector3(0, 0, -1), Vector3.UP)
			else:
				enemy.look_at(enemy.position + Vector3(0, 0, 1), Vector3.UP)
			if enemyGridPosition == playerGridPosition:
				enemyGridPosition.x = enemyGridPosition.x + 1
				enemyFacing = "forward"
				enemyMovePick = int(randf_range(1,5))
				enemyMovePick = "move" + str(enemyMovePick)
				enemyMovePick = enemyMoves[enemyMovePick]
				await hit_test(get_node("/root/MoveDex").MoveDex[enemyMovePick]["AttVector"], get_node("/root/MoveDex").MoveDex[enemyMovePick]["Power"], enemy, enemyFacing)
			await move_on_grid(enemy, enemyGridPosition, 0.08)
		3:
			enemyGridPosition.z = enemyGridPosition.z + 1
			if enemyGridPosition.z == 5:
				enemyGridPosition.z = 3
				enemy.look_at(enemy.position + Vector3(-1, 0, 0), Vector3.UP)
			else:
				enemy.look_at(enemy.position + Vector3(1, 0, 0), Vector3.UP)
			if enemyGridPosition == playerGridPosition:
				enemyGridPosition.z = enemyGridPosition.z - 1
				enemyFacing = "right"
				enemyMovePick = int(randf_range(1,5))
				enemyMovePick = "move" + str(enemyMovePick)
				enemyMovePick = enemyMoves[enemyMovePick]
				await hit_test(get_node("/root/MoveDex").MoveDex[enemyMovePick]["AttVector"], get_node("/root/MoveDex").MoveDex[enemyMovePick]["Power"], enemy, enemyFacing)
			await move_on_grid(enemy, enemyGridPosition, 0.08)
		4:
			enemyGridPosition.z = enemyGridPosition.z - 1
			if enemyGridPosition.z == 1:
				enemyGridPosition.z = 2
				enemy.look_at(enemy.position + Vector3(1, 0, 0), Vector3.UP)
			else:
				enemy.look_at(enemy.position + Vector3(-1, 0, 0), Vector3.UP)
			if enemyGridPosition == playerGridPosition:
				enemyGridPosition.z = enemyGridPosition.z + 1
				enemy.look_at(enemy.position + Vector3(-1, 0, 0), Vector3.UP)
				enemyFacing = "left"
				enemyMovePick = int(randf_range(1,5))
				enemyMovePick = "move" + str(enemyMovePick)
				enemyMovePick = enemyMoves[enemyMovePick]
				await hit_test(get_node("/root/MoveDex").MoveDex[enemyMovePick]["AttVector"], get_node("/root/MoveDex").MoveDex[enemyMovePick]["Power"], enemy, enemyFacing)
			await move_on_grid(enemy, enemyGridPosition, 0.08)
	
	get_node("/root/mapBattle/GUI/PlayerHealth").text = str(playerHP)
	get_node("/root/mapBattle/NME/EnemyHealth").text = str(enemyHP)
	if enemyHP <= 0:
		call_deferred("end_battle")
		return
	if playerHP <= 0:
		call_deferred("end_battle")
		return
	player_turn()

func load_creature(creatureName):
	
	var dex = get_node("/root/mapBattle")
	
	creatureName = load(dex.monDict[creatureName]["MODEL"]).instantiate()
	dex.add_child(creatureName)
	return creatureName

func move_on_grid(creature, creatureNewGridPos, speed):
	var tween = get_tree().create_tween()
	var newX
	var newZ
	
	
	newX = (creatureNewGridPos.x * 2.5) - 6.25
	newZ = (creatureNewGridPos.z * 2.5) - 6.25
	tween.tween_property(creature, "position", Vector3(newX, 0.5, newZ), speed)
	await tween.finished
	return creatureNewGridPos

func calc_HP(basehp, level):
	var hp = floor(0.01 * (2 * basehp + 16 + floor(0.25 * 128)) * level) + level + 10
	return hp

func calc_stats(Battack, level):
	var calcstat = (floor(0.01 * (2 * Battack + 16 + floor(0.25 * 128)) * level) + 5)
	return calcstat

func _input(_event):
	if playerTurn == true && inBattle == true:
		if Input.is_action_just_pressed("forward") && playerChooseToMove == false:
			playerGridPosition.x = clamp(playerGridPosition.x + 1, 1, 4)
			if playerGridPosition == enemyGridPosition:
				playerGridPosition.x = clamp(playerGridPosition.x - 1, 1, 4)
				player.look_at(player.position + Vector3(-1, 0, 0), Vector3.UP)
				playerFacing = "forward"
				get_node("/root/mapBattle/BLOCKED").play()
				return
			player.look_at(player.position + Vector3(-1, 0, 0), Vector3.UP)
			await move_on_grid(player, playerGridPosition, 0.08)
			get_node("/root/mapBattle/FtStep").play()
			playerTurn = false
			playerFacing = "forward"
			emit_signal("MOVE_PICKED")
			
		if Input.is_action_just_pressed("back") && playerChooseToMove == false:
			playerGridPosition.x = clamp(playerGridPosition.x - 1, 1, 4)
			if playerGridPosition == enemyGridPosition:
				playerGridPosition.x = clamp(playerGridPosition.x + 1, 1, 4)
				player.look_at(player.position + Vector3(1, 0, 0), Vector3.UP)
				playerFacing = "back"
				get_node("/root/mapBattle/BLOCKED").play()
				return
			player.look_at(player.position + Vector3(1, 0, 0), Vector3.UP)
			await move_on_grid(player, playerGridPosition, 0.08)
			get_node("/root/mapBattle/FtStep").play()
			playerTurn = false
			playerFacing = "back"
			emit_signal("MOVE_PICKED")
			
		if Input.is_action_just_pressed("left") && playerChooseToMove == false:
			playerGridPosition.z = clamp(playerGridPosition.z - 1, 1, 4)
			if playerGridPosition == enemyGridPosition:
				playerGridPosition.z = clamp(playerGridPosition.z + 1, 1, 4)
				player.look_at(player.position + Vector3(0, 0, 1), Vector3.UP)
				playerFacing = "left"
				get_node("/root/mapBattle/BLOCKED").play()
				return
			player.look_at(player.position + Vector3(0, 0, 1), Vector3.UP)
			await move_on_grid(player, playerGridPosition, 0.08)
			get_node("/root/mapBattle/FtStep").play()
			playerTurn = false
			playerFacing = "left"
			emit_signal("MOVE_PICKED")
			
		if Input.is_action_just_pressed("right") && playerChooseToMove == false:
			playerGridPosition.z = clamp(playerGridPosition.z + 1, 1, 4)
			if playerGridPosition == enemyGridPosition:
				playerGridPosition.z = clamp(playerGridPosition.z - 1, 1, 4)
				player.look_at(player.position + Vector3(0, 0, -1), Vector3.UP)
				playerFacing = "right"
				get_node("/root/mapBattle/BLOCKED").play()
				return
			player.look_at(player.position + Vector3(0, 0, -1), Vector3.UP)
			await move_on_grid(player, playerGridPosition, 0.08)
			get_node("/root/mapBattle/FtStep").play()
			playerTurn = false
			playerFacing = "right"
			emit_signal("MOVE_PICKED")
			
		if Input.is_action_just_pressed("select") && movePicked == false:
			playerChooseToMove = true
		
		if Input.is_action_just_released("interact"):
			enemyHP = 0
			emit_signal("MOVE_PICKED")
			
		if playerChooseToMove == true:
		
			if Input.is_action_just_pressed("forward"):
				playerAttVec = get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party[partyPos]["creatureMoves"]["move1"]]["AttVector"]
				playerMoveChosen = "move1"
				movePicked = true
				player_hitmarker(playerFacing, playerGridPosition, playerAttVec)
				

				
			if Input.is_action_just_pressed("back"):
				playerAttVec = get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party[partyPos]["creatureMoves"]["move4"]]["AttVector"]
				playerMoveChosen = "move4"
				movePicked = true
				player_hitmarker(playerFacing, playerGridPosition, playerAttVec)

				
			if Input.is_action_just_pressed("left"):
				playerAttVec = get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party[partyPos]["creatureMoves"]["move2"]]["AttVector"]
				playerMoveChosen = "move2"
				movePicked = true
				player_hitmarker(playerFacing, playerGridPosition, playerAttVec)

				
			if Input.is_action_just_pressed("right"):
				playerAttVec = get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party[partyPos]["creatureMoves"]["move3"]]["AttVector"]
				playerMoveChosen = "move3"
				movePicked = true
				player_hitmarker(playerFacing, playerGridPosition, playerAttVec)
				
			
			if Input.is_action_just_pressed("select") && movePicked == true:
				await hit_test(playerAttVec, get_node("/root/MoveDex").MoveDex[get_node("/root/PlayerOwn").Party[partyPos]["creatureMoves"][playerMoveChosen]]["Power"], player, playerFacing)
				#print(playerFacing)
func hit_test(attVec, power, attacker, facing):
	var gridPos
	var attack
	var defense
	var level
	var hp
	var enemyGridPos
	
	if attacker == enemy:
		gridPos = enemyGridPosition
		enemyGridPos = playerGridPosition
		attack = enemyAttack
		defense = playerDefense
		level = enemyLevel
		match facing:
			"forward":
				attackingSpot = gridPos + Vector3(attVec, 0, 0)
				await move_on_grid(get_node("/root/mapBattle/HitMarker"), (gridPos + Vector3(attVec, 0, 0)), 0)
				get_node("/root/mapBattle/HitMarker").position.y = 0
				get_node("/root/mapBattle/HitMarker").visible = true
			"back":
				attackingSpot = gridPos + Vector3(-attVec, 0, 0)
				await move_on_grid(get_node("/root/mapBattle/HitMarker"), (gridPos + Vector3(-attVec, 0, 0)), 0)
				get_node("/root/mapBattle/HitMarker").position.y = 0
				get_node("/root/mapBattle/HitMarker").visible = true
			"left":
				attackingSpot = gridPos + Vector3(0, 0, -attVec)
				await move_on_grid(get_node("/root/mapBattle/HitMarker"), (gridPos + Vector3(0, 0, -attVec)), 0)
				get_node("/root/mapBattle/HitMarker").position.y = 0
				get_node("/root/mapBattle/HitMarker").visible = true
			"right":
				attackingSpot = gridPos + Vector3(0, 0, attVec)
				await move_on_grid(get_node("/root/mapBattle/HitMarker"), (gridPos + Vector3(0, 0, attVec)), 0)
				get_node("/root/mapBattle/HitMarker").position.y = 0
				get_node("/root/mapBattle/HitMarker").visible = true
	if attacker == player:
		enemyGridPos = enemyGridPosition
		gridPos = playerGridPosition
		attack = playerAttack
		defense = playerDefense
		level = playerLevel
	if attacker == player:
		await get_tree().create_timer(0.1).timeout
	if attacker == enemy:
		await get_tree().create_timer(0.5).timeout
	get_node("/root/mapBattle/HitMarker").visible = false
	playerChooseToMove = false
	if enemyGridPos == attackingSpot:
		if attacker == enemy:
			hp = playerHP
			var newHP = damage_calc(attack, defense, hp, power, level)
			get_node("/root/mapBattle/HIT").play()
			playerHP = newHP
			return
		if attacker == player:
			hp = enemyHP
			var newHP = damage_calc(attack, defense, hp, power, level)
			get_node("/root/mapBattle/HIT").play()
			enemyHP = newHP
			emit_signal('MOVE_PICKED')
			return
	else:
		if attacker == enemy:
			return
		if attacker == player:
			emit_signal('MOVE_PICKED')
			return
func damage_calc(attack, defense, HP, power, level):
	HP -= floor(((((2 * level * 1) / 5) * power * (attack / defense)) / 50) + 2)
	return HP

func end_battle():
	overworld.remove_child(spawnNode)
	battlescene.free()
	get_node("/root").add_child(overworld)
	get_tree().set_current_scene(overworld)
	battlescene = preload("res://battle.tscn").instantiate()
	get_node("/root/TestWorld").call_deferred("_handle_states", get_node("/root/TestWorld").playerStates.IDLE)
	inBattle = false
	return

func player_hitmarker(facing, gridPos, attVec):
	match facing:
		"forward":
			attackingSpot = gridPos + Vector3(attVec, 0, 0)
			await move_on_grid(get_node("/root/mapBattle/HitMarker"), (gridPos + Vector3(attVec, 0, 0)), 0)
			get_node("/root/mapBattle/HitMarker").position.y = 0
			get_node("/root/mapBattle/HitMarker").visible = true
		"back":
			attackingSpot = gridPos + Vector3(-attVec, 0, 0)
			await move_on_grid(get_node("/root/mapBattle/HitMarker"), (gridPos + Vector3(-attVec, 0, 0)), 0)
			get_node("/root/mapBattle/HitMarker").position.y = 0
			get_node("/root/mapBattle/HitMarker").visible = true
		"left":
			attackingSpot = gridPos + Vector3(0, 0, -attVec)
			await move_on_grid(get_node("/root/mapBattle/HitMarker"), (gridPos + Vector3(0, 0, -attVec)), 0)
			get_node("/root/mapBattle/HitMarker").position.y = 0
			get_node("/root/mapBattle/HitMarker").visible = true
		"right":
			attackingSpot = gridPos + Vector3(0, 0, attVec)
			await move_on_grid(get_node("/root/mapBattle/HitMarker"), (gridPos + Vector3(0, 0, attVec)), 0)
			get_node("/root/mapBattle/HitMarker").position.y = 0
			get_node("/root/mapBattle/HitMarker").visible = true
