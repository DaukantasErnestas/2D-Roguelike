extends Node

var node_creation_parent = null
var player = null

func PlaySound(sound, position, parent):
	var sound_instance = sound.instance()
	parent.add_child(sound_instance)
	sound_instance.global_position = position
	sound_instance.play()
