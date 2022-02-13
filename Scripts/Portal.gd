extends Particles2D

var can_press = false
var can_tween = true

var connection_1_connected = false

func _process(_delta):
	if connection_1_connected == false:
		connection_1_connected = true
		Global.player.connect("debug_mode_toggled",self,"on_debug_mode_toggled")
		
func on_debug_mode_toggled():
	$AreaSprite.visible = Global.debug_mode
	
func _input(event):
	if event.is_action_pressed("Interact") and can_press:
		can_tween = false
		Global.node_creation_parent.portal_entered()

func _on_EntranceArea_body_entered(body):
	if body.is_in_group("Player") and can_tween:
		$Tween.interpolate_property($Popup,"rect_scale",$Popup.rect_scale,Vector2(1,1),0.1,Tween.TRANS_QUAD,Tween.EASE_OUT)
		$Tween.start()
		can_press = true

func _on_EntranceArea_body_exited(body):
	if body.is_in_group("Player") and can_tween:
		$Tween.interpolate_property($Popup,"rect_scale",$Popup.rect_scale,Vector2(1,0),0.1,Tween.TRANS_QUAD,Tween.EASE_OUT)
		$Tween.start()
		can_press = false
