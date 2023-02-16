extends Control

var partySize = get_node("/root/PlayerOwn").Party.size()

func _ready():
	for n in partySize:
		$Fir/Sec.button.new()
