extends Area2D

var room_pos = Vector2(0,0)
var triggered = false
var enemies_to_spawn = 0
var min_spawn_time = 1
var max_spawn_time = 1
var RNG = RandomNumberGenerator.new()
onready var enemy1 = preload("res://Enemies/Enemy1.tscn")
onready var spawner = preload("res://PreEnemySpawner.tscn")

var connection_1_connected = false

var map_icon = "room"

func _process(_delta):
	if connection_1_connected == false:
		connection_1_connected = true
		Global.player.connect("debug_mode_toggled",self,"on_debug_mode_toggled")

func spawn_enemy():
	RNG.randomize()
	var spawner_instance = spawner.instance()
	var picked_position = Vector2.ZERO
	print($TopLeftCorner.global_position)
	print($BottomRightCorner.global_position)
	picked_position.x = RNG.randf_range($TopLeftCorner.global_position.x,$BottomRightCorner.global_position.x)
	picked_position.y = RNG.randf_range($TopLeftCorner.global_position.y,$BottomRightCorner.global_position.y)
	spawner_instance.enemy_to_spawn = enemy1
	Global.node_creation_parent.add_child(spawner_instance)
	print(picked_position)
	spawner_instance.global_position = picked_position
	$SpawnTimer.wait_time = RNG.randf_range(min_spawn_time,max_spawn_time)
	
func on_debug_mode_toggled():
	$CollisionColor.visible = Global.player.debug_mode
	
