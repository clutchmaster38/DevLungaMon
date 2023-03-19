extends Sprite3D
@export var posOffset = Vector3(0,280,-780)

func _process(_delta):
	self.position = get_node("/root/TestWorld/Player").position + posOffset
