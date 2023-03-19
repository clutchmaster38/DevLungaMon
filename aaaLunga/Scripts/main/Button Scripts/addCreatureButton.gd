extends Button


func _on_button_down():
	var snurkey = Pokemon.new("Snurkey", 10, "Ice", ["Tackle", "Tackle", "Tackle", "Tackle"])
	if get_node("/root/PlayerParty").add_pokemon(snurkey) == true:
		snurkey._full_heal()
