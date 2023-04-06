extends CharacterBody3D

@export var speed := 10.0
@export var gravity := -50.0
@export var rotation_speed = 9.0

var mouse_captured: bool = false

var _velocity := Vector3.ZERO

var move_direction := Vector3.ZERO

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _model: Node3D = $Origin

@onready var stepcheck = RayCast3D.new()
@onready var stepcheckforward = RayCast3D.new()
@onready var stepcheckdown = RayCast3D.new()
@onready var newline = Line2D.new()
@onready var dirline = Line2D.new()
@onready var time = 0.0

var accum : float

func _ready():
	add_child(stepcheck)
	add_child(stepcheckforward)
	add_child(stepcheckdown)
	add_child(newline)
	add_child(dirline)
	newline.default_color = Color("Red")
	dirline.default_color = Color("Green")
	
	newline.visible = false
	dirline.visible = false
	
	$Origin/ping/AnimationPlayer.get_animation("PingRun").set_loop_mode(1)
	$Origin/ping/AnimationPlayer.get_animation("PingRunTurnL").set_loop_mode(1)
	$Origin/ping/AnimationPlayer.get_animation("PingRunTurnR").set_loop_mode(1)
	$Origin/ping/AnimationPlayer.get_animation("PingIdle").set_loop_mode(1)

func _player_move(delta: float) -> void:
	
	move_direction = Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	_velocity.x = lerp(_velocity.x,move_direction.x * speed, 0.4)
	_velocity.z = lerp(_velocity.z,move_direction.z * speed, 0.4)
	_velocity.y += gravity * delta
	
	var movevec2d = Vector2(move_direction.x, move_direction.z)
	var velvec2d = Vector2(velocity.x, velocity.z).normalized()
	
	stepcheck.target_position = Vector3(0,0.5,0)
	stepcheckforward.position = stepcheck.target_position
	stepcheckforward.target_position = (Vector3(_velocity.x, 0 , _velocity.z).normalized()) / 2
	stepcheckdown.position = stepcheckforward.target_position
	stepcheckdown.target_position = Vector3(0, -1, 0) / 1.13
	
	if stepcheckdown.is_colliding() == true and $Origin/stepHeight.is_colliding() == false:
		_move_up_stairs()
		
	
	set_velocity(_velocity)
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	_velocity = velocity
	
	
	if _velocity.length() > 5.0 && _velocity.y == 0:
		$Origin/ping/AnimationTree.set("parameters/blend_position", Vector2(velvec2d.angle_to(movevec2d), -1 + _velocity.normalized().length()))
		var look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = lerp_angle(_model.rotation.y, look_direction.angle(), delta * rotation_speed)
	if _velocity.length() < 5.0 && _velocity.length() > 0.2 && _velocity.y == 0:
		var _look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = _look_direction.angle()
		if move_direction == Vector3.ZERO:
			$Origin/ping/AnimationTree.set("parameters/blend_position", Vector2(0,1))
		else:
			$Origin/ping/AnimationTree.set("parameters/blend_position", Vector2(velvec2d.angle_to(movevec2d), -1 + _velocity.normalized().length()))
	
	
	#debug Drawing starts here!
	var start = $SpringArm3D/Camera3D.unproject_position(self.global_transform.origin)
	var end = $SpringArm3D/Camera3D.unproject_position(self.global_transform.origin + velocity.normalized())
	var moveend = $SpringArm3D/Camera3D.unproject_position(self.global_transform.origin + move_direction)
	newline.clear_points()
	newline.add_point(start)
	newline.add_point(end)
	
	dirline.clear_points()
	dirline.add_point(start)
	dirline.add_point(moveend)
	blink(delta)
	
func _move_up_stairs():
	_velocity.y += 4
	var look_direction = Vector2(move_direction.z, move_direction.x)
	_model.rotation.y = look_direction.angle()

func _exit_walking():
	pass
	

func _idle(delta: float) -> void:
	$Origin/ping/AnimationTree.set("parameters/blend_position", Vector2(0,-1))

		
	_velocity.y = gravity
	if is_on_floor() == false:
		set_velocity(_velocity)
		move_and_slide()
	blink(delta)
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
	pass

func _enter_running():
	pass
	
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized() 
	return xform

func blink(delta):
	accum += delta
	if accum >= 10:
		$Origin/ping/Armature/Skeleton3D/pingface.get_active_material(1).set_shader_parameter("offset", 9)
	if accum >= 10.2:
		$Origin/ping/Armature/Skeleton3D/pingface.get_active_material(1).set_shader_parameter("offset", 0)
		accum = 0

	
