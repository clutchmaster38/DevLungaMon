extends Control

var _newPos
var _newRot

func _scene_exit(last: Vector3, next: String, rot: float):
	$AnimationPlayer.play("scene_exit")
	await $AnimationPlayer.animation_finished
	get_node("/root/TestWorld").free()
	get_tree().change_scene_to_file(next)
	_newPos = last
	_newRot = rot
	call_deferred("_scene_enter")
	
func _scene_enter():
	get_node("/root/TestWorld/Player").global_position = _newPos
	get_node("/root/TestWorld/Player")._spring_arm.rotation_degrees.y = _newRot
	get_node("/root/TestWorld/Player")._model.rotation_degrees.y = -_newRot
	$AnimationPlayer.play("scene_enter")


