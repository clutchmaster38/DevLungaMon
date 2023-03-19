extends CharacterBody3D

@export var speed := 10.0
@export var gravity := -500.0
@export var rotation_speed = 20.0

var mouse_captured: bool = false

var _velocity := Vector3.ZERO

var move_direction := Vector3.ZERO

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _model: Node3D = $Origin


func _player_move(delta: float) -> void:
	
	if $Origin/ping/AnimationPlayer.is_playing() == false:
		$Origin/ping/AnimationPlayer.play("PingRun")
	
	move_direction = Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	_velocity.x = lerp(_velocity.x,move_direction.x * speed, 0.3)
	_velocity.z = lerp(_velocity.z,move_direction.z * speed, 0.3)
	_velocity.y = gravity * delta
	
	set_velocity(_velocity)
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	_velocity = velocity
	
	if _velocity.length() > 5.0:
		$Origin/ping/AnimationPlayer.speed_scale = 1
		var look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = lerp_angle(_model.rotation.y, look_direction.angle(), delta * rotation_speed)
	if _velocity.length() < 5.0 && _velocity.length() > 0.2:
		var _look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = _look_direction.angle()
		$Origin/ping/AnimationPlayer.speed_scale = _velocity.length() / 10
	
func _exit_walking():
	$Origin/ping/AnimationPlayer.stop()
	

func _idle():
	$Origin/ping/AnimationPlayer.speed_scale = 1
	if $Origin/ping/AnimationPlayer.is_playing() == false:
		$Origin/ping/AnimationPlayer.play("PingIdle")
		
	_velocity.y = gravity
	if is_on_floor() == false:
		set_velocity(_velocity)
		move_and_slide()

func _pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$pauseBG.visible = true

func _unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$pauseBG.visible = false

func _process(_delta : float) -> void:
	_spring_arm.position = position
	var shadowPoint = $Origin/ping/RayCast3D.get_collision_point()
	$shadow.global_transform = align_with_y(global_transform, get_floor_normal())
	$shadow.global_position.y = shadowPoint.y + 0.005
	$shadow.rotation.x = $shadow.rotation.x + deg_to_rad(90)
	$shadow.scale = Vector3(0.252, 0.252, 0.252)
	
	

func _menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _unmenu():
	$MENU.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _exit_idle():
	if $Origin/ping/AnimationPlayer.is_playing() == true:
		$Origin/ping/AnimationPlayer.stop()

func _enter_running():
	pass
	
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized() 
	return xform
