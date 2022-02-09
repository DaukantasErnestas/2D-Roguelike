extends Node2D

var dungeon = {}
var node_sprite = load("res://Images/Square.png")
var branch_sprite = load("res://Images/Square.png")
var max_enemies = 10
var min_enemies = 5
var max_spawn_time = 3
var min_spawn_time = 1
var RNG = RandomNumberGenerator.new()

var offset = 8
var path_width = 6
var width = 32
var height = 32

var tile_size = 8

onready var map_node = $MapNode
onready var room_entry_area = preload("res://RoomEntryArea.tscn")
onready var room_connection_sprite = preload("res://RoomConnectionSprite.tscn")

func _ready():
	dungeon = dungeon_generation.generate(0)
	Global.node_creation_parent = self
	load_map()
	$Player.global_position = Vector2(width*$Walls.cell_size.x*2/2,height*$Walls.cell_size.y*2/2)
func _exit_tree():
	Global.node_creation_parent = null

func load_map():
	for i in range(0, map_node.get_child_count()):
		map_node.get_child(i).queue_free()
	for i in dungeon.keys():
		RNG.randomize()
		var temp = Sprite.new()
#		temp.texture = node_sprite
#		$CanvasLayer/UI/Minimap/MarginContainer.add_child(temp)
#		temp.z_index = 1
#		temp.position = i * 25
		var area_instance = room_entry_area.instance()
		$RoomAreas.add_child(area_instance)
		area_instance.global_position = Vector2(i.x * (width * 64) / 2 + i.x*offset*32, i.y * (height * 64) / 2 + i.y*offset*32) + Vector2(width*64/4,height*64/4)
		area_instance.get_node("CollisionShape2D").shape.extents = Vector2((width-3)*8,(height-3)*tile_size)
		area_instance.get_node("CollisionColor").rect_size = Vector2((width-3)*8,(height-3)*tile_size)
		area_instance.get_node("CollisionColor").rect_position = -Vector2((width-3)*8,(height-3)*tile_size)
		area_instance.get_node("TopLeftCorner").position = -(area_instance.get_node("CollisionShape2D").shape.extents - Vector2(16,16))
		area_instance.get_node("BottomRightCorner").position = (area_instance.get_node("CollisionShape2D").shape.extents - Vector2(16,16))
		area_instance.enemies_to_spawn = RNG.randi_range(min_enemies,max_enemies)
		area_instance.enemies_to_kill = area_instance.enemies_to_spawn
		area_instance.corresponding_room = dungeon.get(i)
		area_instance.min_spawn_time = min_spawn_time
		area_instance.max_spawn_time = max_spawn_time
		area_instance.room_pos = i
		if i == Vector2.ZERO:
			area_instance.triggered = true
		area_instance.connect("area_entered",self,"room_entered",[area_instance])
		#make a square
		for BlockX in width:
			for BlockY in height:
				if $Walls.get_cell(((i.x * width) + (i.x * offset)) + BlockX, ((i.y * height) + (i.y * offset)) + BlockY) == -1:
					$Walls.set_cell(((i.x * width) + (i.x * offset)) + BlockX, ((i.y * height) + (i.y * offset)) + BlockY, 0)
		#fill the insides with the background tile
		for BlockX in width-2:
			for BlockY in height-2:
				$Background.set_cell(((i.x * width) + (i.x * offset)) + BlockX + 1, ((i.y * height) + (i.y * offset)) + BlockY + 1, 2)
				$Walls.set_cell(((i.x * width) + (i.x * offset)) + BlockX + 1, ((i.y * height) + (i.y * offset)) + BlockY + 1, -1)
		var c_rooms = dungeon.get(i).connected_rooms
		if(c_rooms.get(Vector2(1, 0)) != null):
			temp = room_connection_sprite.instance()
			temp.texture = branch_sprite
			temp.scale = Vector2(0.75,0.75)
			$ConnectionNodes.add_child(temp)
			temp.direction = "X"
			temp.z_index = 0
			#new new implementation
			temp.position += Vector2(i.x * (width + offset) * tile_size*4/5 + width * tile_size*4/5 + offset * tile_size*2/5,i.y * (height + offset) * tile_size*4/5 + height * tile_size*2/5)
			temp.modulate = Color("a95757")
			temp.modulate.a = 0
			print(temp.position)
			
			for BlockX in offset:
				#walls
				$Walls.set_cell((i.x * width + i.x * offset) + (width+BlockX), (i.y * height + i.y * offset) + height/2+path_width/2,0)
				$Walls.set_cell((i.x * width + i.x * offset) + (width+BlockX), (i.y * height + i.y * offset) + height/2-path_width/2 -1,0)
			#room wall removal
			for BlockY in path_width:
				$Walls.set_cell((i.x * width + i.x * offset) + (width)-1, (i.y * height + i.y * offset) + (height/2-path_width/2) + BlockY,1)
			for BlockY in path_width:
				$Walls.set_cell((i.x * width + i.x * offset) + (width+offset), (i.y * height + i.y * offset) + (height/2-path_width/2) + BlockY,1)
			#background filler
			for BlockY in path_width:
				for BlockX in offset + 2:
					$Background.set_cell((i.x * width + i.x * offset) + (width+BlockX) - 1, (i.y * height + i.y * offset) + height/2-path_width/2 + BlockY,2)
		if(c_rooms.get(Vector2(0, 1)) != null):
			temp = room_connection_sprite.instance()
			temp.texture = branch_sprite
			temp.scale = Vector2(0.75,0.75)
			$ConnectionNodes.add_child(temp)
			temp.direction = "Y"
			temp.z_index = 0
			temp.rotation_degrees = 90
			temp.modulate = Color("5773a9")
			temp.modulate.a = 0
			#new new implementation
			temp.position += Vector2(i.x * (width + offset) * tile_size*4/5 + width * tile_size*2/5,i.y * (height + offset) * tile_size*4/5 + height * tile_size*4/5 + offset * tile_size*2/5)
			
			for BlockY in offset:
				$Walls.set_cell((i.x * width + i.x * offset) + (width/2+path_width/2), (i.y * height + i.y * offset) + (height+BlockY),0)
				$Walls.set_cell((i.x * width + i.x * offset) + (width/2-path_width/2 -1), (i.y * height + i.y * offset) + (height+BlockY),0)
			#room wall removal
			for BlockY in path_width:
				$Walls.set_cell( (i.x * width + i.x * offset) + (width/2-path_width/2) + BlockY,(i.y * height + i.y * offset) + (height)-1,1)
			for BlockY in path_width:
				$Walls.set_cell((i.x * width + i.x * offset) + (width/2-path_width/2) + BlockY, (i.y * height + i.y * offset) + (height+offset),1)
			#background filler
			for BlockX in path_width:
				for BlockY in offset + 2:
					$Background.set_cell((i.x * width + i.x * offset) + (width/2-path_width/2 + BlockX), (i.y * height + i.y * offset) + (height) + BlockY -1,2)
	post_gen()

func post_gen():
	for room in dungeon[Vector2(0,0)].connected_rooms:
		if dungeon[Vector2(0,0)].connected_rooms[room] != null:
			dungeon[Vector2(0,0)].connected_rooms[room].discovered = true
	var connection_tiles = $Walls.get_used_cells_by_id(1)
	for tile in connection_tiles:
		$Walls.set_cellv(tile,-1)
	var bg_tiles = $Background.get_used_cells_by_id(2)
	for tile in bg_tiles:
		if (wrapi(int(tile.x),0, 10) >= 5 and wrapi(int(tile.y),0, 10) < 5) or (wrapi(int(tile.x),0, 10) < 5 and wrapi(int(tile.y),0, 10) >= 5):
			$Background.set_cellv(tile,3)

func room_entered(area,room_area):
	if area.get_parent().is_in_group("Player") and room_area.triggered == false:
		var i = room_area.room_pos
		for room in dungeon[i].connected_rooms:
			if dungeon[i].connected_rooms[room] != null:
				dungeon[i].connected_rooms[room].discovered = true
		room_area.triggered = true
		for BlockX in width:
			$Walls.set_cell(((i.x * width) + (i.x * offset)) + BlockX,(i.y * height) + (i.y * offset),0)
			$Walls.set_cell(((i.x * width) + (i.x * offset)) + BlockX,(i.y * height) + (i.y * offset) + height-1,0)
		for BlockY in height:
			$Walls.set_cell((i.x * width) + (i.x * offset),(i.y * height) + (i.y * offset) + BlockY,0)
			$Walls.set_cell((i.x * width) + (i.x * offset) + width-1,(i.y * height) + (i.y * offset) + BlockY,0)
		room_area.get_node("SpawnTimer").wait_time = RNG.randf_range(min_spawn_time,max_spawn_time)
		room_area.get_node("SpawnTimer").start()
		
func room_cleared(room_area,room):
	var i = room_area.room_pos
	#X
	#Right
	if room.connected_rooms.get(Vector2(1,0)) != null:
		for BlockY in path_width:
			$Walls.set_cell((i.x * (width + offset)) + (width)-1, (i.y * height + i.y * offset) + (height/2-path_width/2) + BlockY,-1)
	#Left
	if room.connected_rooms.get(Vector2(-1,0)) != null:
		for BlockY in path_width:
			$Walls.set_cell((i.x * (width + offset)), (i.y * height + i.y * offset) + (height/2-path_width/2) + BlockY,-1)
	#Y
	#Bottom
	if room.connected_rooms.get(Vector2(0,1)) != null:
		for BlockX in path_width:
			$Walls.set_cell( (i.x * width + i.x * offset) + (width/2-path_width/2) + BlockX,(i.y * height + i.y * offset) + (height)-1,-1)
	#Top
	if room.connected_rooms.get(Vector2(0,-1)) != null:
		for BlockX in path_width:
			$Walls.set_cell( (i.x * width + i.x * offset) + (width/2-path_width/2) + BlockX,(i.y * height + i.y * offset),-1)

