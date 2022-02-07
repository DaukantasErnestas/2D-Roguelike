extends MarginContainer

export(float) var zoom = 1
export(float) var zoom_increment = 0.01

onready var grid = $MarginContainer/Grid
onready var player_marker = $MarginContainer/PlayerMarker
onready var room_marker = $MarginContainer/Contents/RoomMarker
onready var room_connection_marker = $MarginContainer/Contents/RoomConnectionMarker

onready var undiscovered_room_marker = preload("res://Images/UndiscoveredRoomMinimapIcon.png")
onready var basic_room_marker = preload("res://Images/RoomMapIcon.png")

onready var icons = {"room": room_marker,"room_connection": room_connection_marker}

var grid_scale
var markers = {}

func _ready():
	player_marker.position = grid.rect_size / 2
	grid_scale = grid.rect_size / (get_viewport_rect().size * zoom)
	var map_objects = get_tree().get_nodes_in_group("map_object")
	for item in map_objects:
		var new_marker = icons[item.map_icon].duplicate()
		$MarginContainer/Contents.add_child(new_marker)
		new_marker.show()
		markers[item] = new_marker

func _process(_delta):
	var map_objects = get_tree().get_nodes_in_group("map_object")
	for item in map_objects:
		if markers.has(item) == false:
			var new_marker = icons[item.map_icon].duplicate()
			$MarginContainer/Contents.add_child(new_marker)
			new_marker.show()
			markers[item] = new_marker
	if Global.player == null:
		push_warning("Player does not exist! Minimap failed!")
		return
	player_marker.rotation = Global.player.rotation
	player_marker.position = $MarginContainer.rect_size / 2
	if Input.is_action_pressed("minimap_zoom_in"):
		zoom += zoom_increment
	if Input.is_action_pressed("minimap_zoom_out"):
		zoom -= zoom_increment
	zoom = clamp(zoom, 0.25,2)
	player_marker.scale = Vector2(0.25*zoom,0.25*zoom)
#	grid.rect_scale = Vector2(zoom,zoom)
#	grid.rect_size = Vector2(116,116)/zoom
#	grid.rect_position = (Vector2(6,6) + Vector2(116,116)/2) * zoom
	var kmarkers = markers.keys()
	for item in markers:
		if item.map_icon == "room":
			var obj_pos = (item.position * zoom - Global.player.position * zoom) * 0.1 + grid.rect_size / 2 
			markers[item].position = obj_pos
			markers[item].scale = Vector2(2,2) * zoom
			if kmarkers[kmarkers.find(item)].corresponding_room.discovered == true:
				markers[item].texture = basic_room_marker
			else:
				markers[item].texture = undiscovered_room_marker
		elif item.map_icon == "room_connection":
			var obj_pos = (item.global_position * zoom - Global.player.position * zoom) * 0.1 + grid.rect_size / 2 
			markers[item].position = obj_pos
			if item.direction == "X":
				markers[item].rotation = PI/2
			elif item.direction == "Y":
				markers[item].rotation = PI
			markers[item].scale = Vector2(2,2) * zoom
		markers[item].visible = true
	
