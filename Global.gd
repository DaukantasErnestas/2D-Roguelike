extends Node

var node_creation_parent = null
var player = null
var camera = null
var minimap = null
var map_zoom = 1

var debug_mode = false
var vine_mode = false

func PlaySound(sound, position, parent, volume = 0):
	var sound_instance = sound.instance()
	parent.add_child(sound_instance)
	if sound_instance is AudioStreamPlayer2D:
		sound_instance.global_position = position
	sound_instance.volume_db = volume
	sound_instance.play()
	
func Update_Minimap():
	for item in minimap.markers:
		minimap.markers[item].queue_free()
	minimap.markers = {}
	var map_objects = get_tree().get_nodes_in_group("map_object")
	for item in map_objects:
		var new_marker = minimap.icons[item.map_icon].duplicate()
		minimap.get_node("MarginContainer/Contents").add_child(new_marker)
		new_marker.show()
		minimap.markers[item] = new_marker
