extends Button

var newPotion

func _on_button_down():
	newPotion = Item.new("Potion", "Heals 20 HP", 0, 20)
	get_node("/root/PlayerItems").add_item(newPotion)
	


