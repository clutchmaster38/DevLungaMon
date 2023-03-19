extends Node

class_name Pokemon

@export var pokemonName: String
@export var level: int
@export var type: String
@export var moves: Array
@export var hp: int
@export var xp: int

func _init(pokemonName: String = "Testagon", level: int = 5, type: String = "Ice", moves: Array = ["Tackle, Tackle, Tackle, Tackle"]):
	self.pokemonName = pokemonName
	self.level = level
	self.type = type
	self.moves = moves
	self.xp = pow(level, 3)
	
func _full_heal():
	hp = _get_max_hp()

func _get_max_hp():
	return floor(0.01 * (2 * get_node("/root/Dex").monDict[pokemonName]["BHP"] + 16 + floor(0.25 * 128)) * level) + level + 10

func _speed():
	return (floor(0.01 * (2 * get_node("/root/Dex").monDict[pokemonName]["BSPEED"] + 16 + floor(0.25 * 128)) * level) + 5)

func _attack():
	return (floor(0.01 * (2 * get_node("/root/Dex").monDict[pokemonName]["BATTACK"] + 16 + floor(0.25 * 128)) * level) + 5)
	
func _defense():
	return (floor(0.01 * (2 * get_node("/root/Dex").monDict[pokemonName]["BDEFENSE"] + 16 + floor(0.25 * 128)) * level) + 5)

func _special_attack():
	return (floor(0.01 * (2 * get_node("/root/Dex").monDict[pokemonName]["BSPAT"] + 16 + floor(0.25 * 128)) * level) + 5)

func _special_defense():
	return (floor(0.01 * (2 * get_node("/root/Dex").monDict[pokemonName]["BSPDF"] + 16 + floor(0.25 * 128)) * level) + 5)

func calc_new_xp(enemyLevel):
	var EXP_EARNED = 128 * enemyLevel / 7
	xp = xp + EXP_EARNED
	return EXP_EARNED

func calc_new_level():
	level = floori(pow(xp, 1.0/3.0))
