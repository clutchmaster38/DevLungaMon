extends CharacterBody3D

@export var speed := 12.0
@export var gravity := -500.0
@export var rotation_speed = 20.0


var _velocity := Vector3.ZERO
var _snap_vector := Vector3.ZERO

signal idle
signal walking

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _model: Node3D = $Origin


func _physics_process(delta: float) -> void:
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
	if _velocity.length() < 5.0 && _velocity.length() > 0.2:
		var _look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = _look_direction.angle()
	
	
func _process(_delta : float) -> void:
	_spring_arm.position = position
