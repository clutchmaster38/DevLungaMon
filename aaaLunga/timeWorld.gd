extends WorldEnvironment
var time
var timeFloat
var matPara

func _ready():
	time = Time.get_time_dict_from_system()
	time = time["hour"]
	#time = 1.0
	matPara = self.environment.sky.get_material()
	timeFloat = time / 24
	matPara.set_shader_parameter("timeh", timeFloat)
	self.environment.ambient_light_energy = (-abs(float(time-12))+12.7) / 12

func _input(_event):
	if Input.is_action_just_pressed("select"):
		time += 1
		time = time % 24
		timeFloat = float(time) / 24.0
		matPara.set_shader_parameter("timeh", timeFloat)
		self.environment.ambient_light_energy = (-abs(float(time-12))+12.7) / 12
		

