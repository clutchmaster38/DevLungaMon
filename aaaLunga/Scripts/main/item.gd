extends Node

class_name Item

@export var itemName: String
@export var description: String
@export var effect_value: int
@export var method: int


var effect_func = [
	restore_hp,
	revive
]

func _init(itemName: String = "Potion", description: String = "Heals 20 HP", method: int = 0, effect_value: int = 20):
	self.itemName = itemName
	self.description = description
	self.effect_value = effect_value

func use(pokemon: Pokemon):
	effect_func[method].call(pokemon, effect_value)
	self.get_parent().remove_child(self)
	self.call_deferred("free")

func restore_hp(pokemon: Pokemon, amount: int):
	pokemon.hp = min(pokemon.hp + amount, pokemon._get_max_hp())

func revive(pokemon: Pokemon) -> bool:
	if pokemon.hp == 0:
		pokemon.hp = pokemon._get_max_hp() / 2
		return true
	else:
		return false
