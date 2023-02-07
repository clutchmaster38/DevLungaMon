extends Node


func _input(event):
	if event.is_action_pressed("escape") and get_parent().current_state != 5:
		if get_parent().current_state == 0 or 2:
			get_tree().paused = !get_tree().paused
	if get_tree().paused == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_parent()._handle_states(get_parent().playerStates.PAUSE)
		$pauseBG.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$pauseBG.visible = false
