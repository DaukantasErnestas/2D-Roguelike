extends Area2D

var room_pos = Vector2(0,0)
var triggered = false

var map_icon = "room"

func _process(_delta):
	if Global.player.debug_mode:
		$CollisionColor.visible = true
	else:
		$CollisionColor.visible = false
