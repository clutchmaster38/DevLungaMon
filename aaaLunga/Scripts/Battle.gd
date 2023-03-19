extends "res://Scripts/main/pokemon.gd"

@export var creatureName = "NULL"
@export var creatureLevel = 5.0
@export var creatureNature = 28
@export var move1: String
@export var move2: String
@export var move3: String
@export var move4: String

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		body.get_node("PlayerStates")._set_state(body.get_node("PlayerStates").player_states.BATTLE)
		get_node("/root/BatLogic").call_deferred("start_battle", creatureName, creatureLevel, creatureNature, move1, move2, move3, move4)
		get_node("/root/BatLogic").spawnNode = self
