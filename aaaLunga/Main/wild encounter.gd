extends Node3D

@export var pokemon: Pokemon
@export var wildList: Node
@export var chance: float


func _ready():
	var rng = RandomNumberGenerator.new()
	var wildchance = rng.randf()
	if chance > wildchance:
		queue_free()

func _on_area_3d_body_entered(body):
	if body.name == "Player" && get_node("/root/PlayerParty").get_party_size() != 0:
		body.get_node("PlayerStates")._set_state(body.get_node("PlayerStates").player_states.BATTLE)
		get_node("/root/BatLogic").call_deferred("start_battle", pokemon)
		get_node("/root/BatLogic").spawnNode = self
