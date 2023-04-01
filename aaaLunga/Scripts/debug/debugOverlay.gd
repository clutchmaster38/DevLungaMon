extends Control

@onready var player = get_parent().get_parent()
@onready var camera = get_parent().get_parent().get_node("SpringArm3D/Camera3D")


func _draw():
	var start = camera.unproject_position(player.global_transform.origin)
	var end = camera.unproject_position(player.global_transform.origin + player.velocity)
	self.draw_line(start, end, Color(0, 1, 0), 0)
