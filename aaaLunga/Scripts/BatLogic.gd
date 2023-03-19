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
var playerPokemon
var player
var playerGridPosition
var playerBHP
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
var enemyPokemon
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
	enemyPokemon = Pokemon.new(creatureName, creatureLevel, "Ice", [move1, move2, move3, move4])
	add_child(enemyPokemon)
	enemyName = creatureName
	enemy = load_creature(creatureName)
	enemyGridPosition = Vector3(4, 0, 4)
	await move_on_grid(enemy, enemyGridPosition, 0)
	
	enemyBHP = get_node("/root/mapBattle").monDict[creatureName]["BHP"]
	enemyLevel = creatureLevel
	enemyPokemon._full_heal()
	enemyHP = enemyPokemon.hp
	enemyMoves = {
		"move1" = move1,
		"move2" = move2,
		"move3" = move3,
		"move4" = move4
	}
	
	get_node("/root/mapBattle/NME/EnemyBar").max_value = enemyHP
	get_node("/root/mapBattle/NME/EnemyBar").value = enemyHP
	
	#load player Pokemon
	playerPokemon = get_node("/root/PlayerParty").get_pokemon(0)
	player = load_creature(playerPokemon.pokemonName) 
	playerGridPosition = Vector3(1, 0, 1)
	await move_on_grid(player, playerGridPosition, 0)
	
	playerBHP = get_node("/root/mapBattle").monDict[playerPokemon.pokemonName]["BHP"]
	playerLevel = playerPokemon.level
	
	get_node("/root/mapBattle/GUI/PlayerBar").max_value = playerPokemon._get_max_hp()
	get_node("/root/mapBattle/GUI/PlayerBar").value = playerPokemon.hp
	
	get_node("/root/mapBattle/joyPad/Top").text = playerPokemon.moves[0]
	get_node("/root/mapBattle/joyPad/Bottom").text = playerPokemon.moves[3]
	get_node("/root/mapBattle/joyPad/Left").text = playerPokemon.moves[1]
	get_node("/root/mapBattle/joyPad/Right").text = playerPokemon.moves[2]
	
	playerMoves = {
		"move1" = playerPokemon.moves[0],
		"move2" = playerPokemon.moves[1],
		"move3" = playerPokemon.moves[2],
		"move4" = playerPokemon.moves[3]
	}
	
	if playerPokemon._speed() > enemyPokemon._speed():
		call_deferred("player_turn")
		return
	else:
		call_deferred("enemy_turn")
		return

func player_turn():
	movePicked = false
	playerTurn = true
	await MOVE_PICKED
	get_node("/root/mapBattle/GUI/PlayerBar").value = playerPokemon.hp
	get_node("/root/mapBattle/NME/EnemyBar").value = enemyHP
	if enemyHP <= 0:
		call_deferred("end_battle")
		return
	if playerPokemon.hp <= 0:
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
	
	get_node("/root/mapBattle/GUI/PlayerBar").value = playerPokemon.hp
	get_node("/root/mapBattle/NME/EnemyBar").value = enemyHP
	if enemyHP <= 0:
		call_deferred("end_battle")
		return
	if playerPokemon.hp <= 0:
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
				playerAttVec = get_node("/root/MoveDex").MoveDex[playerPokemon.moves[0]]["AttVector"]
				playerMoveChosen = playerPokemon.moves[0]
				movePicked = true
				player_hitmarker(playerFacing, playerGridPosition, playerAttVec)
				

				
			if Input.is_action_just_pressed("back"):
				playerAttVec = get_node("/root/MoveDex").MoveDex[playerPokemon.moves[3]]["AttVector"]
				playerMoveChosen = playerPokemon.moves[3]
				movePicked = true
				player_hitmarker(playerFacing, playerGridPosition, playerAttVec)

				
			if Input.is_action_just_pressed("left"):
				playerAttVec = get_node("/root/MoveDex").MoveDex[playerPokemon.moves[1]]["AttVector"]
				playerMoveChosen = playerPokemon.moves[1]
				movePicked = true
				player_hitmarker(playerFacing, playerGridPosition, playerAttVec)

				
			if Input.is_action_just_pressed("right"):
				playerAttVec = get_node("/root/MoveDex").MoveDex[playerPokemon.moves[2]]["AttVector"]
				playerMoveChosen = playerPokemon.moves[2]
				movePicked = true
				player_hitmarker(playerFacing, playerGridPosition, playerAttVec)
				
			
			if Input.is_action_just_pressed("select") && movePicked == true:
				await hit_test(playerAttVec, get_node("/root/MoveDex").MoveDex[playerMoveChosen]["Power"], player, playerFacing)
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
		attack = enemyPokemon._attack()
		defense = playerPokemon._defense()
		level = enemyPokemon.level
		match facing:
			"back":
				attackingSpot = gridPos + Vector3(attVec, 0, 0)
				await move_on_grid(get_node("/root/mapBattle/HitMarker"), (gridPos + Vector3(attVec, 0, 0)), 0)
				get_node("/root/mapBattle/HitMarker").position.y = 0
				get_node("/root/mapBattle/HitMarker").visible = true
			"forward":
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
		attack = playerPokemon._attack()
		defense = playerPokemon._defense()
		level = playerPokemon.level
	if attacker == player:
		await get_tree().create_timer(0.1).timeout
	if attacker == enemy:
		await get_tree().create_timer(0.5).timeout
	get_node("/root/mapBattle/HitMarker").visible = false
	playerChooseToMove = false
	if enemyGridPos == attackingSpot:
		if attacker == enemy:
			hp = playerPokemon.hp
			var newHP = damage_calc(attack, defense, hp, power, level)
			get_node("/root/mapBattle/HIT").play()
			playerPokemon.hp = newHP
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
	playerPokemon.calc_new_xp(enemyLevel)
	playerPokemon.calc_new_level()
	overworld.remove_child(spawnNode)
	battlescene.free()
	get_node("/root").add_child(overworld)
	get_tree().set_current_scene(overworld)
	battlescene = preload("res://battle.tscn").instantiate()
	get_node("/root/TestWorld/Player/PlayerStates").call_deferred("_set_state", get_node("/root/TestWorld/Player/PlayerStates").player_states.IDLE)
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
