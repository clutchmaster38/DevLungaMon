extends "res://Scripts/main/stateMachine.gd"

enum menu_states {MAIN, PARTY, ITEM, OPTIONS, TRAINER, DEBUG, NONE}


func _ready():
	call_deferred("_set_state",menu_states.NONE)

func _state_logic(delta):
	match state:
		menu_states.NONE:
			if parent.get_node("PlayerStates").state == parent.get_node("PlayerStates").player_states.MENU:
				_set_state(menu_states.MAIN)
		menu_states.MAIN:
			if Input.is_action_just_released("menu"):
				_set_state(menu_states.NONE)
			if parent.get_node("MENU").get_node("GridContainer").get_node("PARTY").button_pressed == true:
				_set_state(menu_states.PARTY)
			if parent.get_node("MENU").get_node("GridContainer").get_node("DEBUG").button_pressed == true:
				_set_state(menu_states.DEBUG)
			if parent.get_node("MENU").get_node("GridContainer").get_node("BAG").button_pressed == true:
				_set_state(menu_states.ITEM)
		menu_states.PARTY:
			parent.get_node("PARTY").call_deferred("partyLogic")
			if Input.is_action_just_pressed("menu"):
				_set_state(menu_states.NONE)
		menu_states.DEBUG:
			if Input.is_action_just_pressed("menu"):
				_set_state(menu_states.NONE)
		menu_states.ITEM:
			if Input.is_action_just_pressed("menu"):
				_set_state(menu_states.NONE)

func _get_transition(delta):
	return null
	
func _enter_state(new_state, old_state):
	if new_state == menu_states.MAIN:
		parent.get_node("MENU").scale.y = 0.0
		parent.get_node("MENU").visible = true
		var tween = get_tree().create_tween()
		tween.tween_property(parent.get_node("MENU"), "scale", Vector2(1, 1), 0.08)
		await tween.finished
	if new_state != menu_states.MAIN:
		parent.get_node("MENU").visible = false
	if new_state == menu_states.PARTY:
		parent.get_node("PARTY").drawParty()
		parent.get_node("PARTY").visible = true	
	if new_state != menu_states.PARTY:
		parent.get_node("PARTY").visible = false
	if new_state == menu_states.DEBUG:
		parent.get_node("DEBUG").visible = true
	if new_state != menu_states.DEBUG:
		parent.get_node("DEBUG").visible = false
	if new_state == menu_states.ITEM:
		parent.get_node("BAG").visible = true
		parent.get_node("BAG").populate_items()
	if new_state != menu_states.ITEM:
		parent.get_node("BAG").visible = false
		
func _exit_state(old_state, new_state):
	if old_state == menu_states.PARTY:
		parent.get_node("PARTY").call_deferred("deleteParty")
	if old_state == menu_states.ITEM:
		parent.get_node("BAG").depopulate_items()
