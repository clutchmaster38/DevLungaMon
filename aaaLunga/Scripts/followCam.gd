extends Camera3D

func _physics_process(delta):
	self.global_transform = get_node("/root/TestWorld/Player/SpringArm3D/Camera3D").global_transform
