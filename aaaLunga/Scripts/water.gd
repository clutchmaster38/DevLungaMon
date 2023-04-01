extends MeshInstance3D

@onready var beach = get_node("/root/TestWorld/beach1/Plane")

func _process(_delta):
	var material = self.get_active_material(0)
	material.set_shader_parameter("position", beach.position)
