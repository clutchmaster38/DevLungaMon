extends Control

var menuChanged = false

signal selected

var menuCounter = Vector2(1,1)
var isTicking = false
var ticker_text

var move_direction := Vector3.ZERO

var menuOpen = false
var PartymenuOpen = false
var OnTexture = load("res://Mats/OnMenu.png")
var OffTexture = load("res://Mats/OffMenu.png")

func drawParty():
	var partySize = get_node("/root/PlayerParty").get_party_size()
	for i in partySize:
		var newbut = load("res://Main/partySel.tscn").instantiate()
		get_node("VFD").add_child(newbut)
		newbut.get_child(1).play("static")
		match i:
			0:
				newbut.position = Vector2(-59.5, -84)
			1:
				newbut.position = Vector2(59.5, -84)
			2:
				newbut.position = Vector2(-59.5, 0)
			3:
				newbut.position = Vector2(59.5, 0)
			4:
				newbut.position = Vector2(-59.5, 84)
			5:
				newbut.position = Vector2(59.5, 84)
		newbut.get_node("BUTTON").text = "\n"
		newbut.get_node("BUTTON").text += get_node("/root/PlayerParty").pokemon[i].pokemonName
		newbut.get_node("HEALTH VU/Level").text = "\n"
		newbut.get_node("HEALTH VU/Level").text += str(get_node("/root/PlayerParty").get_pokemon(i).level).pad_zeros(3)
		newbut.get_node("BUTTON").text = newbut.get_node("BUTTON").text.to_upper()
		newbut.get_node("BUTTON").visible_characters = 7
		newbut.get_node("VU/ColorRect").position.x = ((get_node("/root/PlayerParty").get_pokemon(i).hp / get_node("/root/PlayerParty").get_pokemon(i)._get_max_hp()) * 74) - 38
	menuOpen = true

func partyLogic():
	if menuOpen == true:
		if Input.is_action_just_pressed("left"):
			menuCounter.y -= 1
			menuCounter.y = wrap(menuCounter.y, 1, 3)
			menuChanged = true
		if Input.is_action_just_pressed("right"):
			menuCounter.y += 1
			menuCounter.y = wrap(menuCounter.y, 1, 3)
			menuChanged = true
		if Input.is_action_just_pressed("forward"):
			menuCounter.x -= 1
			menuCounter.x = wrap(menuCounter.x, 1, 4)
			menuChanged = true
		if Input.is_action_just_pressed("back"):
			menuCounter.x += 1
			menuCounter.x = wrap(menuCounter.x, 1, 4)
			menuChanged = true
		if Input.is_action_just_pressed("interact"):
			emit_signal("selected")
	if menuOpen == true and get_node("/root/PlayerParty").get_party_size() != 0:
		match menuCounter:
			Vector2(1,1):
				for i in $VFD.get_children():
					if i != $VFD.get_child(0):
						i.texture = OffTexture
						i.z_index = 0
						i.get_child(1).play("static")
				$VFD.get_child(0).texture = OnTexture
				$VFD.get_child(0).z_index = 3
				$VFD.get_child(0).get_child(1).play("snurkey")
				if isTicking == false:
					_on_menu_tick(0)
			Vector2(1,2):
				if get_node("/root/PlayerParty").get_party_size() <= 1:
					menuCounter.y -= 1
					return
				for i in $VFD.get_children():
					if i != $VFD.get_child(1):
						i.texture = OffTexture
						i.z_index = 0
						i.get_child(1).play("static")
				$VFD.get_child(1).texture = OnTexture
				$VFD.get_child(1).z_index = 3
				$VFD.get_child(1).get_child(1).play("sel")
				if isTicking == false:
					_on_menu_tick(1)
			Vector2(2,1):
				if get_node("/root/PlayerParty").get_party_size() <= 2:
					menuCounter = Vector2(1,2)
					return
				for i in $VFD.get_children():
					if i != $VFD.get_child(2):
						i.texture = OffTexture
						i.z_index = 0
						i.get_child(1).play("static")
				$VFD.get_child(2).texture = OnTexture
				$VFD.get_child(2).z_index = 3
				$VFD.get_child(2).get_child(1).play("sel")
				if isTicking == false:
					_on_menu_tick(2)
			Vector2(2,2):
				if get_node("/root/PlayerParty").get_party_size() <= 3:
					menuCounter.y -= 1
					return
				for i in $VFD.get_children():
					if i != $VFD.get_child(3):
						i.texture = OffTexture
						i.z_index = 0
						i.get_child(1).play("static")
				$VFD.get_child(3).texture = OnTexture
				$VFD.get_child(3).z_index = 3
				$VFD.get_child(3).get_child(1).play("sel")
				if isTicking == false:
					_on_menu_tick(3)
			Vector2(3,1):
				if get_node("/root/PlayerParty").get_party_size() <= 4:
					menuCounter = Vector2(2,2)
					return
				for i in $VFD.get_children():
					if i != $VFD.get_child(4):
						i.texture = OffTexture
						i.z_index = 0
						i.get_child(1).play("static")
				$VFD.get_child(4).texture = OnTexture
				$VFD.get_child(4).z_index = 3
				$VFD.get_child(4).get_child(1).play("sel")
				if isTicking == false:
					_on_menu_tick(4)
			Vector2(3,2):
				if get_node("/root/PlayerParty").get_party_size() <= 5:
					menuCounter.y -= 1
					return
				for i in $VFD.get_children():
					if i != $VFD.get_child(5):
						i.texture = OffTexture
						i.z_index = 0
						i.get_child(1).play("static")
				$VFD.get_child(5).texture = OnTexture
				$VFD.get_child(5).z_index = 3
				$VFD.get_child(5).get_child(1).play("sel")
				if isTicking == false:
					_on_menu_tick(5)
					
func _on_menu_tick(partyPlace):
	menuChanged = false
	isTicking = true
	ticker_text = get_node("/root/PlayerParty").get_pokemon(partyPlace).pokemonName + "   "
	ticker_text = ticker_text.to_upper()
	for l in ticker_text.length():
		if menuChanged == true:
			$VFD.get_child(partyPlace).get_child(0).text = "\n" + ticker_text
			isTicking = false
			return
		await get_tree().create_timer(0.5).timeout
		if menuOpen == false:
			return
		$VFD.get_child(partyPlace).get_child(0).text = "\n" + ticker_text.substr(l, 6)
		
		if l + 6 > ticker_text.length():
			$VFD.get_child(partyPlace).get_child(0).text += ticker_text.substr(0, l + 6 - ticker_text.length())
		
	isTicking = false
	return

func deleteParty():
	menuOpen = false
	isTicking = false
	for n in $VFD.get_children():
		$VFD.remove_child(n)
		n.queue_free()

func chooseCreature():
	await selected
	return ((menuCounter.x * 2) + menuCounter.y)- 3
