extends Node

var pokemon: Array
var max_pokemon: int = 6

func add_pokemon(new_pokemon: Pokemon) -> bool:
	if pokemon.size() < max_pokemon:
		pokemon.append(new_pokemon)
		self.add_child(new_pokemon)
		return true
	else:
		return false

func remove_pokemon(pokemon_index: int) -> bool:
	if pokemon_index >= 0 and pokemon_index < pokemon.size():
		pokemon.remove_at(pokemon_index)
		return true
	else:
		return false

func get_pokemon(pokemon_index: int) -> Pokemon:
	if pokemon_index >= 0 and pokemon_index < pokemon.size():
		return pokemon[pokemon_index]
	else:
		return null

func swap_pokemon(index_1: int, index_2: int):
	if index_1 >= 0 and index_1 < pokemon.size() and index_2 >= 0 and index_2 < pokemon.size():
		var temp = pokemon[index_1]
		pokemon[index_1] = pokemon[index_2]
		pokemon[index_2] = temp

func get_party_size() -> int:
	return pokemon.size()

func is_party_full() -> bool:
	return pokemon.size() == max_pokemon
