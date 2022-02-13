extends Node

func _ready():
	$SelfDestructTimer.connect("timeout",self,"SelfDestruct")

func SelfDestruct():
	queue_free()
