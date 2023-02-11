extends Node

enum playerStates {IDLE, BATTLE, WALKING, MENU, PAUSE, INTERACT}

var current_state


func _ready():
	_handle_states(playerStates.IDLE)
	
func _handle_states(new_state):
	current_state = new_state
	
	match current_state:
		playerStates.IDLE:
			#print(current_state)
			pass
		playerStates.BATTLE:
			#print(current_state)
			pass
		playerStates.WALKING:
			#print(current_state)
			pass
		playerStates.MENU:
			#print(current_state)
			pass
		playerStates.PAUSE:
			#print(current_state)
			pass
		playerStates.INTERACT:
			#print(current_state)
			pass
	

func _on_player_idle():
	_handle_states(playerStates.IDLE)


func _on_player_walking():
	_handle_states(playerStates.WALKING)
