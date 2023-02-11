extends Control

func _scene_exit(last: Vector3, next: String):
	$AnimationPlayer.play("scene_exit")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(next)
	get_node("/root/TestWorld/Player").position = last
	_scene_enter()
	
func _scene_enter():
	$AnimationPlayer.play("scene_enter")


