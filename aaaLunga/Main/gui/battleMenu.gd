extends Control

var arrowPosition = Vector2(0,0)
signal move_chosen(move)

func _physics_process(_delta):
	arrowPosition.x = wrapi(arrowPosition.x,0,2)
	arrowPosition.y = wrapi(arrowPosition.y,0,2)
	$Selecto/Arrow.position = Vector2((arrowPosition.y * 443) + 90, (arrowPosition.x * 110) + 90)
	$Fight/Arrow.position = Vector2((arrowPosition.y * 443) + 90, (arrowPosition.x * 110) + 90)
	if Input.is_action_just_pressed("forward"):
		arrowPosition.x = arrowPosition.x - 1
	if Input.is_action_just_pressed("back"):
		arrowPosition.x = arrowPosition.x + 1
	if Input.is_action_just_pressed("left"):
		arrowPosition.y = arrowPosition.y - 1
	if Input.is_action_just_pressed("right"):
		arrowPosition.y = arrowPosition.y + 1
	if Input.is_action_just_pressed("interact"):
		match arrowPosition:
			Vector2(0,0):
				if $Selecto.visible == true:
					call_deferred("fight")
				if $Fight.visible == true:
					emit_signal("move_chosen", 0)
			Vector2(0,1):
				if $Fight.visible == true:
					emit_signal("move_chosen", 1)
			Vector2(1,0):
				if $Selecto.visible == true:
					#select a Pokemon
					emit_signal("move_chosen", 4)
				if $Fight.visible == true:
					emit_signal("move_chosen", 2)
			Vector2(1,1):
				if $Selecto.visible == true:
					#RUN a Pokemon
					emit_signal("move_chosen", 5)
				if $Fight.visible == true:
					emit_signal("move_chosen", 3)

func fight():
	$Selecto.visible = false
	$Fight.visible = true
	
func reset():
	$Fight.visible = false
	$Selecto.visible = true
	arrowPosition = Vector2(0,0)

func set_moves(moves: Array):
	$Fight/m0.text = moves[0]
	$Fight/m1.text = moves[1]
	$Fight/m2.text = moves[2]
	$Fight/m3.text = moves[3]
