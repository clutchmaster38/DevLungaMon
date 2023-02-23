extends CharacterBody3D

@export var speed := 10.0
@export var gravity := -500.0
@export var rotation_speed = 20.0


var _velocity := Vector3.ZERO
var _snap_vector := Vector3.ZERO

signal idle
signal walking

var menuChanged = false

var menuCounter = Vector2(1,1)
var isTicking = false
var ticker_text

var menuOpen = false
var OnTexture = load("res://Mats/OnMenu.png")
var OffTexture = load("res://Mats/OffMenu.png")

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _model: Node3D = $Origin


func _physics_process(delta: float) -> void:
	
	if get_parent().current_state == 3:
		return
	
	if get_parent().current_state != 5:
		var move_direction := Vector3.ZERO
		move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
		move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
		_velocity.x = lerp(_velocity.x,move_direction.x * speed, 0.3)
		_velocity.z = lerp(_velocity.z,move_direction.z * speed, 0.3)
		_velocity.y = gravity * delta
	
	
	
		var _just_landed := is_on_floor() and _snap_vector == Vector3.ZERO
		set_velocity(_velocity)
		set_up_direction(Vector3.UP)
		set_floor_stop_on_slope_enabled(true)
		move_and_slide()
		_velocity = velocity
		
	if _velocity.length() > 5.0 && get_parent().current_state != 5:
		emit_signal("walking")
		var look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = lerp_angle(_model.rotation.y, look_direction.angle(), delta * rotation_speed)
		if $FtStep.playing == false && is_on_floor():
			$FtStep.play(0)
	if _velocity.length() < 0.2 && get_parent().current_state != 5:
		emit_signal("idle")
		if $Origin/ping/AnimationPlayer.is_playing() == false:
			$Origin/ping/AnimationPlayer.play("PingIdle")

	if _velocity.length() < 5.0 && _velocity.length() > 0.2:
		var _look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = _look_direction.angle()
	
	
func _process(_delta : float) -> void:
	_spring_arm.position = position
	if Input.is_action_just_pressed("interact"):
		get_node("/root/Save")._save()
	if Input.is_action_just_pressed("menu") && get_parent().current_state == 0:
		get_parent()._handle_states(get_parent().playerStates.MENU)
		_open_menu()
	if Input.is_action_just_pressed("menu") && get_parent().current_state == 2:
		get_parent()._handle_states(get_parent().playerStates.MENU)
		_open_menu()
	if Input.is_action_just_released("menu") && menuOpen == false:
		get_parent()._handle_states(get_parent().playerStates.IDLE)
		call_deferred("_close_menu")
	if Input.is_action_pressed("escape") && menuOpen == true:
		get_parent()._handle_states(get_parent().playerStates.IDLE)
		$PARTY.visible = false
		$DEBUG.visible = false
		for n in $PARTY/VFD.get_children():
			n.queue_free()
		_close_menu()
		menuOpen = false
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
			
		match menuCounter:
			Vector2(1,1):
				for i in $PARTY/VFD.get_children():
					i.texture = OffTexture
					i.z_index = 0
				$PARTY/VFD.get_child(0).texture = OnTexture
				$PARTY/VFD.get_child(0).z_index = 3
				if isTicking == false:
					_on_menu_tick()
			Vector2(1,2):
				for i in $PARTY/VFD.get_children():
					i.texture = OffTexture
					i.z_index = 0
				$PARTY/VFD.get_child(1).texture = OnTexture
				$PARTY/VFD.get_child(1).z_index = 3
			Vector2(2,1):
				for i in $PARTY/VFD.get_children():
					i.texture = OffTexture
					i.z_index = 0
				$PARTY/VFD.get_child(2).texture = OnTexture
				$PARTY/VFD.get_child(2).z_index = 3
			Vector2(2,2):
				for i in $PARTY/VFD.get_children():
					i.texture = OffTexture
					i.z_index = 0
				$PARTY/VFD.get_child(3).texture = OnTexture
				$PARTY/VFD.get_child(3).z_index = 3
			Vector2(3,1):
				for i in $PARTY/VFD.get_children():
					i.texture = OffTexture
					i.z_index = 0
				$PARTY/VFD.get_child(4).texture = OnTexture
				$PARTY/VFD.get_child(4).z_index = 3
			Vector2(3,2):
				for i in $PARTY/VFD.get_children():
					i.texture = OffTexture
					i.z_index = 0
				$PARTY/VFD.get_child(5).texture = OnTexture
				$PARTY/VFD.get_child(5).z_index = 3
		
func _open_menu():
	$MENU.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _close_menu():
	$MENU.visible = false
	menuChanged = true
	isTicking = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_pressed():
	$PARTY.visible = true
	menuOpen = true
	get_parent()._handle_states(get_parent().playerStates.MENU)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var partySize = get_node("/root/PlayerOwn").Party.size()
	for i in partySize:
		var newbut = load("res://Main/partySel.tscn").instantiate()
		get_node("PARTY/VFD").add_child(newbut)
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
		newbut.get_node("BUTTON").text += get_node("/root/PlayerOwn").Party["creature" + str(i+1)]["creatureName"]
		newbut.get_node("BUTTON").text = newbut.get_node("BUTTON").text.to_upper()
		newbut.get_node("BUTTON").visible_characters = 7




func _on_button_DEBUG_pressed():
	$DEBUG.visible = true
	menuOpen = true
	get_parent()._handle_states(get_parent().playerStates.MENU)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_menu_tick():
	menuChanged = false
	isTicking = true
	ticker_text = get_node("/root/PlayerOwn").Party["creature1"]["creatureName"] + "   "
	ticker_text = ticker_text.to_upper()
	for l in ticker_text.length():
		if menuChanged == true:
			isTicking = false
			return
		await get_tree().create_timer(1.0).timeout
		if menuOpen == false:
			return
		$PARTY/VFD.get_child(0).get_child(0).text = "\n" + ticker_text.substr(l, 6)
		
		if l + 6 > ticker_text.length():
			$PARTY/VFD.get_child(0).get_child(0).text += ticker_text.substr(0, l + 6 - ticker_text.length())
		
		print(l)
		print("Menu Change? is " + str(menuChanged))
		print("is Ticking ? is" + str(isTicking))
	isTicking = false
	return
