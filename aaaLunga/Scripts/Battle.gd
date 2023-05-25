extends "res://Scripts/main/pokemon.gd"

@export var pokemon: Pokemon

func _on_area_3d_body_entered(body):
	if body.name == "Player" && get_node("/root/PlayerParty").get_party_size() != 0:
		body.get_node("PlayerStates")._set_state(body.get_node("PlayerStates").player_states.BATTLE)
		get_node("/root/BatLogic").call_deferred("start_battle", pokemon)
		get_node("/root/BatLogic").spawnNode = self
