extends Control

var connection_1_connected = false

func _process(delta):
	$Debug/VBoxContainer/Frames/VBoxContainer/FPS_Counter.text = "FPS: " + String(Engine.get_frames_per_second())
	if Global.debug_mode:
		$Debug/VBoxContainer/Frames/VBoxContainer/Frame_Time_Counter.text = "Frame time: " + String(stepify(delta * 1000,0.01)) + "ms"
		$Debug/VBoxContainer/Other/VBoxContainer/Player_Rotation.text = "Player rotation: %s rad (%s°)" % [String(Global.player.rotation),String(Global.player.rotation_degrees)]
		$Debug/VBoxContainer/Other/VBoxContainer/Player_Pos.text = "Player position: %s" % Global.player.global_position
		$Debug/VBoxContainer/Other/VBoxContainer/Player_Immune.text = "Player immune: %s" % Global.player.immune
		$Debug/VBoxContainer/Other/VBoxContainer/Player_Def_Color.text = "Player default color: %s" % Global.player.color
		$Debug/VBoxContainer/Other/VBoxContainer/Player_Curr_Color.text = "Player current color: %s" % Global.player.get_node("Sprite").modulate
	if connection_1_connected == false:
		connection_1_connected = true
		Global.player.connect("debug_mode_toggled",self,"on_debug_mode_toggled")
		
func _physics_process(delta):
	if Global.debug_mode:
		$Debug/VBoxContainer/Frames/VBoxContainer/Phys_FPS_Counter.text = "Physics FPS: " + String(Engine.iterations_per_second)
		$Debug/VBoxContainer/Frames/VBoxContainer/Phys_Frame_Time_Counter.text = "Physics frame time: " + String(stepify(delta * 1000,0.01)) + "ms"
		
func on_debug_mode_toggled():
	$Debug/VBoxContainer/Frames/VBoxContainer/FPS_Counter.visible = Global.debug_mode
	$Debug/VBoxContainer/Frames/VBoxContainer/Phys_FPS_Counter.visible = Global.debug_mode
	$Debug/VBoxContainer/Frames/VBoxContainer/Frame_Time_Counter.visible = Global.debug_mode
	$Debug/VBoxContainer/Frames/VBoxContainer/Phys_Frame_Time_Counter.visible = Global.debug_mode
	$Debug/VBoxContainer/Other/VBoxContainer/Player_Rotation.visible = Global.debug_mode
	$Debug/VBoxContainer/Other/VBoxContainer/Player_Pos.visible = Global.debug_mode
	$Debug/VBoxContainer/Other/VBoxContainer/Player_Immune.visible = Global.debug_mode
	$Debug/VBoxContainer/Other/VBoxContainer/Player_Curr_Color.visible = Global.debug_mode
	$Debug/VBoxContainer/Other/VBoxContainer/Player_Def_Color.visible = Global.debug_mode
