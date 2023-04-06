extends TextureRect

@onready var partySel = preload("res://Main/party.tscn").instantiate()

var partyOpen = false

func populate_items():
	for i in get_node("/root/PlayerItems").items:
		$ItemList.add_item(i.itemName.to_upper())
	

func depopulate_items():
	$ItemList.clear()
	if partySel != null:
		partySel.queue_free()
		partySel = preload("res://Main/party.tscn").instantiate()
		partyOpen = false

func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	var item = get_node("/root/PlayerItems").get_item(index)
	get_parent().add_child(partySel)
	partySel.visible = true
	partyOpen = true
	partySel.drawParty()
	var creature = await partySel.chooseCreature()
	partySel.deleteParty()
	get_parent().remove_child(partySel)
	
	get_node("/root/PlayerItems").use_item(item, get_node("/root/PlayerParty").get_pokemon(creature))
	$ItemList.remove_item(index)

func _physics_process(delta):
	if partyOpen == true:
		partySel.call_deferred("partyLogic")
