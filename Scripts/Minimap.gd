extends MarginContainer

export(float) var min_zoom = 0.15
export(float) var max_zoom = 2
export(float) var zoom_increment = 0.01

onready var grid = $MarginContainer/Grid
onready var player_marker = $MarginContainer/PlayerMarker
onready var enemy_marker = $MarginContainer/Contents/EnemyMarker
onready var room_marker = $MarginContainer/Contents/RoomMarker
onready var room_connection_marker = $MarginContainer/Contents/RoomConnectionMarker

onready var undiscovered_room_marker = preload("res://Images/UndiscoveredRoomMinimapIcon.png")
onready var basic_room_marker = preload("res://Images/RoomMapIcon.png")
onready var home_room_marker = preload("res://Images/HomeRoomMinimapIcon.png")
onready var boss_room_marker = preload("res://Images/BossRoomMinimapIcon.png")

onready var icons = {"room": room_marker,"room_connection": room_connection_marker, "enemy": enemy_marker}
onready var room_icons = {"undiscovered": undiscovered_room_marker, "basic": basic_room_marker, "boss": boss_room_marker, "home": home_room_marker}

var grid_scale
var markers = {}

func _ready():
	Global.minimap = self
	player_marker.position = grid.rect_size / 2
	grid_scale = grid.rect_size / (get_viewport_rect().size * Global.map_zoom)
	var map_objects = get_tree().get_nodes_in_group("map_object")
	for item in map_objects:
		var new_marker = icons[item.map_icon].duplicate()
		$MarginContainer/Contents.add_child(new_marker)
		new_marker.show()
		markers[item] = new_marker

func _exit_tree():
	Global.minimap = null

func _process(_delta):
	if Global.player == null:
		push_warning("Player does not exist! Minimap failed!")
		return
	player_marker.rotation = Global.player.rotation
	player_marker.position = $MarginContainer.rect_size / 2
	if Input.is_action_pressed("minimap_zoom_in"):
		Global.map_zoom += zoom_increment
	if Input.is_action_pressed("minimap_zoom_out"):
		Global.map_zoom -= zoom_increment
	Global.map_zoom = clamp( Global.map_zoom, min_zoom , max_zoom )
	player_marker.scale = Vector2(0.25*Global.map_zoom,0.25*Global.map_zoom)
#	grid.rect_scale = Vector2(Global.map_zoom,Global.map_zoom)
#	grid.rect_size = Vector2(116,116)/Global.map_zoom
#	grid.rect_position = (Vector2(6,6) + Vector2(116,116)/2) * Global.map_zoom
	var kmarkers = markers.keys()
	for item in markers:
		if item.map_icon == "room":
			var obj_pos = (item.position * Global.map_zoom - Global.player.position * Global.map_zoom) * 0.075 + grid.rect_size / 2 
			markers[item].position = obj_pos
			markers[item].scale = Vector2(2,2) * Global.map_zoom
			if kmarkers[kmarkers.find(item)].corresponding_room.discovered == true:
				if room_icons.has(kmarkers[kmarkers.find(item)].corresponding_room.room_type):
					markers[item].texture = room_icons[kmarkers[kmarkers.find(item)].corresponding_room.room_type]
				else:
					markers[item].texture = room_icons["undiscovered"]
			else:
				markers[item].texture = undiscovered_room_marker
		elif item.map_icon == "room_connection":
			var obj_pos = (item.global_position * Global.map_zoom - Global.player.position * Global.map_zoom) * 0.075 + grid.rect_size / 2 
			markers[item].position = obj_pos
			if item.direction == "X":
				markers[item].rotation = PI/2
			elif item.direction == "Y":
				markers[item].rotation = PI
			markers[item].scale = Vector2(2,2) * Global.map_zoom
		elif item.map_icon == "enemy":
			var obj_pos = (item.position * Global.map_zoom - Global.player.position * Global.map_zoom) * 0.075 + grid.rect_size / 2 
			markers[item].position = obj_pos
			markers[item].scale = Vector2(.1,.1) * Global.map_zoom
		markers[item].visible = true
