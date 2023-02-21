extends Node

@export var creatureName = "NULL"
@export var creatureLevel = 5.0
@export var creatureNature = 28
@export var creatureMoves = {
	"move1" = "Tackle",
	"move2" = "Tackle",
	"move3" = "Tackle",
	"move4" = "Tackle",
}

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		get_node("/root/Global").call_deferred("load_wild_creature")
		get_node("/root/Global").playerLoc = %Player.position
		get_node("/root/Global").spawnNode = self
		get_node("/root/Global").currentMap = ("res://battle.tscn")
		get_node("/root/Global").call_deferred("switch_scene")
