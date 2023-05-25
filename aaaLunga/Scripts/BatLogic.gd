extends Node

@onready var battlescene = preload("res://battle.tscn").instantiate()
@onready var menu = preload("res://Main/gui/battleMenu.tscn").instantiate()
@onready var partySel = preload("res://Main/party.tscn").instantiate()
@onready var spawnNode
var overworld
var inBattle = false
var partyOpen = false

var enemyPokemon
var enemyMDL

var creatureNUM

var playerPokemon
var playerMDL

func _physics_process(delta):
	if partyOpen == true:
		partySel.call_deferred("partyLogic")

func load_creature(creatureName):
	
	var dex = get_node("/root/mapBattle")
	
	creatureName = load(dex.monDict[creatureName]["MODEL"]).instantiate()
	dex.add_child(creatureName)
	return creatureName

func start_battle(enemy: Pokemon):
	
	creatureNUM = 0
	
	enemy.get_parent().remove_child(enemy)
	self.add_child(enemy)
	
	overworld = get_node("/root/TestWorld")
	get_node("/root").remove_child(overworld)
	get_node("/root").add_child(battlescene)
	
	enemyPokemon = enemy
	enemyMDL = load_creature(enemyPokemon.pokemonName)
	enemyMDL.global_position = get_node("/root/mapBattle/EnemySpot").global_position
	
	playerPokemon = get_node("/root/PlayerParty").get_pokemon(0)
	playerMDL = load_creature(playerPokemon.pokemonName)
	playerMDL.global_position = get_node("/root/mapBattle/PlayerSpot").global_position

	enemyMDL.look_at(playerMDL.global_position)
	enemyMDL.rotation.y += deg_to_rad(90)
	
	playerMDL.look_at(enemyMDL.global_position)
	playerMDL.rotation.y += deg_to_rad(180)
	
	get_node("/root/mapBattle/NME/EnemyBar").max_value = enemyPokemon._get_max_hp()
	get_node("/root/mapBattle/NME/EnemyBar").value = enemyPokemon._get_max_hp()
	
	enemyPokemon.hp = enemyPokemon._get_max_hp()
	
	get_node("/root/mapBattle/GUI/PlayerBar").max_value = get_node("/root/PlayerParty").get_pokemon(0)._get_max_hp()
	get_node("/root/mapBattle/GUI/PlayerBar").value = get_node("/root/PlayerParty").get_pokemon(0).hp
	
	menu.set_moves(get_node("/root/PlayerParty").get_pokemon(0).moves)
	
	if enemyPokemon._speed() > playerPokemon._speed():
		enemies_turn()
	else:
		players_turn()

func players_turn():
	if menu.get_parent() != get_node("/root/mapBattle"):
		get_node("/root/mapBattle").add_child(menu)
	var move = await menu.move_chosen
	
	if move <= 3:
		var newHP = damage_calc(playerPokemon._attack(), enemyPokemon._defense(), enemyPokemon.hp, get_node("/root/MoveDex").MoveDex[playerPokemon.moves[move]]["Power"], playerPokemon.level)
		enemyPokemon.hp = newHP
	elif move == 4:
		get_parent().add_child(partySel)
		partySel.visible = true
		partyOpen = true
		partySel.drawParty()
		var creature = await partySel.chooseCreature()
		partySel.deleteParty()
		get_parent().remove_child(partySel)
		if get_node("/root/PlayerParty").get_pokemon(creature) == playerPokemon:
			menu.reset()
			partySel.queue_free()
			partySel = preload("res://Main/party.tscn").instantiate()
			partyOpen = false
			partySel.deleteParty()
			players_turn()
			return
		else:
			change_creature(get_node("/root/PlayerParty").get_pokemon(creature))
			creatureNUM = creature
	elif move == 5:
		call_deferred("end_battle")
		return
	menu.reset()
	if partySel != null:
		partySel.queue_free()
		partySel = preload("res://Main/party.tscn").instantiate()
		partyOpen = false
	get_node("/root/mapBattle").remove_child(menu)
	
	get_node("/root/mapBattle/NME/EnemyBar").value = enemyPokemon.hp
	get_node("/root/mapBattle/GUI/PlayerBar").value = get_node("/root/PlayerParty").get_pokemon(creatureNUM).hp
	
	if enemyPokemon.hp <= 0:
		call_deferred("end_battle")
	if playerPokemon.hp <= 0:
		lose()
	else:
		enemies_turn()
	
func enemies_turn():
	var newHP = damage_calc(enemyPokemon._attack(), playerPokemon._defense(), playerPokemon.hp, get_node("/root/MoveDex").MoveDex[enemyPokemon.moves[int(randf_range(0,4))]]["Power"], enemyPokemon.level)
	playerPokemon.hp = newHP
	
	get_node("/root/mapBattle/NME/EnemyBar").value = enemyPokemon.hp
	get_node("/root/mapBattle/GUI/PlayerBar").value = get_node("/root/PlayerParty").get_pokemon(creatureNUM).hp
	
	players_turn()

func damage_calc(attack, defense, HP, power, level):
	HP -= floor(((((2 * level * 1) / 5) * power * (attack / defense)) / 50) + 2)
	return HP

func end_battle():
	playerPokemon.calc_new_xp(enemyPokemon.level)
	playerPokemon.calc_new_level()
	overworld.remove_child(spawnNode)
	battlescene.free()
	get_node("/root").add_child(overworld)
	get_tree().set_current_scene(overworld)
	battlescene = preload("res://battle.tscn").instantiate()
	get_node("/root/TestWorld/Player/PlayerStates").call_deferred("_set_state", get_node("/root/TestWorld/Player/PlayerStates").player_states.IDLE)
	return

func lose():
	pass

func change_creature(newmon):
	playerMDL.free()
	playerPokemon = newmon
	playerMDL = load_creature(newmon.pokemonName)
	playerMDL.global_position = get_node("/root/mapBattle/PlayerSpot").global_position
	get_node("/root/mapBattle/GUI/PlayerBar").max_value = newmon._get_max_hp()
	get_node("/root/mapBattle/GUI/PlayerBar").value = newmon.hp
