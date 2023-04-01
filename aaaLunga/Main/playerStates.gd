extends stateMachine

enum player_states {IDLE, BATTLE, WALKING, MENU, PAUSE, INTERACT}

func _ready():
	call_deferred("_set_state",player_states.IDLE)

func _state_logic(delta):
	match state:
		player_states.IDLE:
			if Input.get_vector("left", "right", "forward", "back") != Vector2.ZERO:
				_set_state(player_states.WALKING)
			elif Input.is_action_just_pressed("escape"):
				_set_state(player_states.PAUSE)
			elif Input.is_action_just_pressed("menu"):
				_set_state(player_states.MENU)
			else:
				parent._idle()
				
		player_states.WALKING:
			parent._player_move(delta)
			if parent._velocity == Vector3.ZERO:
				_set_state(player_states.IDLE)
			elif Input.is_action_just_pressed("menu"):
				_set_state(player_states.MENU)
		player_states.PAUSE:
			parent._pause()
			if Input.is_action_just_pressed("escape"):
				_set_state(player_states.IDLE)
			if Input.is_action_just_pressed("interact"):
				get_node("/root/Save")._save()
		player_states.MENU:
			pass
			if parent.get_node("MenuStates").state == parent.get_node("MenuStates").menu_states.NONE:
				_set_state(player_states.IDLE)
		player_states.INTERACT:
			if parent.get_node("Origin/ping/AnimationPlayer").is_playing() == true:
				parent.get_node("Origin/ping/AnimationPlayer").play("PingIdle")
			
func _get_transition(_delta):
	return null
	
func _enter_state(new_state, old_state):
	if new_state == player_states.MENU:
		parent._menu()
	if new_state == player_states.WALKING:
		parent._enter_running()
	
func _exit_state(old_state, new_state):
	if old_state == player_states.IDLE && new_state == player_states.WALKING:
		parent._exit_idle()
	if old_state == player_states.WALKING && new_state != player_states.INTERACT:
		parent._exit_walking()
	if old_state == player_states.PAUSE:
		parent._unpause()
	if old_state == player_states.MENU:
		parent._unmenu()
