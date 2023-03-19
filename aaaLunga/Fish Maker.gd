extends Node

var boids = 32
var fish
@onready var fishTexture = load("res://Mats/fish.png")


var velocity = Vector3(0,0,0)
var maxLeg = 0.0133
var lookDir

func _ready():
	for i in boids:
		fish = Sprite3D.new()
		fish.texture = fishTexture
		self.add_child(fish)
		fish.texture_filter = 0
		fish.render_priority = 8
		randomize()
		var randomx = randf_range(-100,100)
		var randomy = randf_range(0,1)
		var randomz = randf_range(-100,100)
		fish.position = Vector3(randomx,randomy,randomz)

func _physics_process(_delta):
	for b in get_children():
		var v1 = rule1(b) # Boids flock to the center of mass
		var v2 = rule2(b) # Boids avoid other boids
		var v3 = rule3(b) # Boids try to match the speed of other boids
		# additional rules can be added directly after

		var finalVector = v1 + v2 + v3
		velocity += finalVector # Adjust direction and speed
		b.position += velocity # Update the position to the new position
		if velocity.length() > maxLeg:
			velocity = (velocity / velocity.length()) * maxLeg
		lookDir = Vector2(velocity.x, velocity.z)
		b.rotation.y = lookDir.angle()
		b.position.x = wrapf(b.position.x, -100, 100)
		b.position.y = wrapf(b.position.y, 0, 1)
		b.position.z = wrapf(b.position.z, -100, 100)
		
func rule1(b):
	var pC = Vector3(0,0,0)
	for b2 in get_children():
		if b != b2:
			pC += b2.position
	pC = pC / (boids - 1)
	var result = (pC - b.position) / 800 # 0.5% towards the percieved center
	return(result)

func rule2(b):
	var distance = .2 # Threshold of distance between boids
	var result = Vector3(0, 0, 0)
	for b2 in get_children():
		if b != b2: # Ignore duplicate boids
			if b.position.distance_to(b2.position) < distance:
				result -= (b2.position - b.position)
	return(result)

func rule3(b):
	var pV = Vector3(0, 0, 0) # Number of dimensions can change
	for b2 in get_children():
		if b != b2: # Ignore duplicate boids
			pV += velocity
	pV = pV / (boids - 1)
	var result = (pV - velocity) / 800 # 0.5% towards the percieved center
	return(result)
