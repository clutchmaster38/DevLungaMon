extends TextureRect

func populate_items():
	for i in get_node("/root/PlayerItems").items:
		$ItemList.add_item(i.itemName.to_upper())

func depopulate_items():
	$ItemList.clear()

func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	var item = get_node("/root/PlayerItems").get_item(index)
	get_node("/root/PlayerItems").use_item(item, get_node("/root/PlayerParty").get_pokemon(0))
	$ItemList.remove_item(index)
