extends Area3D

@export var signText = "You are reading!"
@onready var isReading = false
var Reading = false:
	set(_value):
		Reading = !Reading
		_on_read()
		
var doneReading = false
var timer = 0
var currentChar = 0

const SPEED = 0.01
		
		
func _ready() -> void:
	set_monitoring(true)
	$NinePatchRect/RichTextLabel.text = signText
	$NinePatchRect/RichTextLabel.visible_ratio = 0.01
	
func _on_body_entered(body):
	if body.name == "Player":
		isReading = true


func _on_body_exited(body):
	if body.name == "Player":
		isReading = false

func _unhandled_input(_event):
	if isReading == true and Input.is_action_just_pressed("interact"):
		Reading = Reading

func _on_read():
	if Reading == true:
		get_node("/root/TestWorld/Player/PlayerStates")._set_state(get_node("/root/TestWorld/Player/PlayerStates").player_states.INTERACT)
		$NinePatchRect.visible = true
	if Reading == false && doneReading == true:
		get_node("/root/TestWorld/Player/PlayerStates")._set_state(get_node("/root/TestWorld/Player/PlayerStates").player_states.IDLE)
		$NinePatchRect.visible = false
		currentChar = 0

func _physics_process(delta):
	if Reading == true:
		timer += delta
		if timer > SPEED:
			timer = 0
			$NinePatchRect/RichTextLabel.visible_ratio = currentChar
			currentChar += 0.03
		if $NinePatchRect/RichTextLabel.visible_ratio == 1:
			doneReading = true

