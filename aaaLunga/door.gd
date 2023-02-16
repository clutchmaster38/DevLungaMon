extends Area3D

@export var current: Vector3
@export var next: String
@export var rot: float

func _on_body_entered(body):
	if body.name == "Player":
		get_node("/root/Transitition")._scene_exit(current, next, rot)
