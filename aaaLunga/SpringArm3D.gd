extends SpringArm3D

@export var mouse_sensitivity := 0.5
var line
var sunPoint
var sunSpec

func _ready() -> void:
	set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	sunSpec = Sprite2D.new()
	sunSpec.texture = load("res://Mats/sprite3Ds/white_flare.png")
	add_child(sunSpec)
	line = Sprite2D.new()
	line.texture = load("res://Mats/sprite3Ds/white_flare.png")
	add_child(line)
	sunPoint = get_node("/root/TestWorld/WorldEnvironment/sun").global_rotation.x
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.get_mouse_mode() == 2:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
		
		sunPoint = get_node("/root/TestWorld/WorldEnvironment/sun").global_rotation.x
		
		var linePoint1 = get_viewport().get_visible_rect().size / 2
		var linePoint2 = get_viewport().get_camera_3d().unproject_position((get_node("/root/TestWorld/Player").global_position) + Vector3(0,0,600).rotated(Vector3(1,0,0), sunPoint))
		
		line.position.x = (1.0/4.0 * linePoint1.x) + (3.0/4.0 * linePoint2.x)
		line.position.y = (1.0/4.0 * linePoint1.y) + (3.0/4.0 * linePoint2.y)
		
		sunSpec.position = linePoint2
		
func _physics_process(delta):
	
	var query = PhysicsRayQueryParameters3D.create($Camera3D.global_position,(get_node("/root/TestWorld/Player").global_position) + Vector3(0,0,600).rotated(Vector3(1,0,0), sunPoint))
		
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result.is_empty() == true && get_viewport().get_camera_3d().is_position_behind((get_node("/root/TestWorld/Player").global_position) + Vector3(0,0,600).rotated(Vector3(1,0,0), sunPoint)) == false:
		line.visible = true
		sunSpec.visible = true
	else:
		line.visible = false
		sunSpec.visible = false

			
