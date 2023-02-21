extends Node3D

var v1 = Vector3(0,0,0)
var v2
var v3

var velocity = Vector3(0,0,0)

var centerPos = Vector3(0,0,0)
var boidCounter = 0
var isCounting = false

func _process(_delta):
	velocity = velocity + v1
	self.position = self.position + velocity
	if isCounting == false:
		Move_Fish()

func Move_Fish():
	for i in get_parent().get_children():
		isCounting = true
		centerPos = centerPos + i.position
		boidCounter += 1
		if boidCounter >= 16:
			centerPos = centerPos / 16
			v1 = (centerPos - self.position)
			print(v1)
			centerPos = Vector3(0,0,0)
			boidCounter = 0
			isCounting = false
