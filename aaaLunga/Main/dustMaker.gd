extends Node3D

func onStep():
	var dust = Sprite3D.new()
	dust.texture = load("res://Mats/sprite3Ds/LensSecond.png")
	get_node("/root/").add_child(dust)
	var tween = create_tween()
	tween.tween_property(dust, "modulate", Color(1, 1, 1, 0), 3)
	await tween.finished
	get_node("/root/").remove_child(dust)
	self.queue_free()
	return
	
