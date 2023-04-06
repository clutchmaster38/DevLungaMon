extends Node

var items: Array

func get_item(item_index: int) -> Item:
	return items[item_index]

func add_item(new_item: Item) -> bool:
	items.append(new_item)
	self.add_child(new_item)
	return true

func use_item(item: Item, pokemon: Pokemon):
	item.use(pokemon)
	items.erase(item)
