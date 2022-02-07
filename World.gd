extends Node2D

var dungeon = {}
var node_sprite = load("res://Images/Square.png")
var branch_sprite = load("res://Images/Square.png")
var max_enemies = 25
var min_enemies = 15
var max_spawn_time = 4
var min_spawn_time = 1
var RNG = RandomNumberGenerator.new()

var offset = 6
var path_width = 6
var width = 24
var height = 24

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
			#new implementation
			var widthCell = width-offset     #width size of the cell itself (tiles unit size)
			var heightCell = height-offset   #height size of the cell itself (tiles unit size)
			
			var WsizeCell = tile_size * widthCell  #corrected cell width size to pixels
			var HsizeCell = tile_size * heightCell #corrected cell height size to pixels
			
			
			temp.position  = Vector2(0,0)    #value of origin cell position
			temp.position += Vector2(WsizeCell/2,HsizeCell/2)  #translation to the middle of the cell
			temp.position += Vector2(tile_size/2,tile_size/2)  #translation to of the cube itself to the middle
			temp.position += i*Vector2(tile_size*(width),tile_size*(height))  #offset by cell position offset
			temp.position += Vector2(WsizeCell/2,0)+Vector2(tile_size*offset/2,0) #since we are in a function that places red boxes (which are always to the right of the cell, we offset by the room/2 + offset/2
			temp.modulate = Color("a95757")
			temp.modulate.a = 0
			
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
			#new implementation
			var widthCell = width-offset     #width size of the cell itself (tiles unit size)
			var heightCell = height-offset   #height size of the cell itself (tiles unit size)
			
			var WsizeCell = tile_size * widthCell  #corrected cell width size to pixels
			var HsizeCell = tile_size * heightCell #corrected cell height size to pixels
			
			
			temp.position  = Vector2(0,0)    #value of origin cell position
			temp.position += Vector2(WsizeCell/2,HsizeCell/2)  #translation to the middle of the cell
			temp.position += Vector2(tile_size/2,tile_size/2)  #translation to of the cube itself to the middle
			temp.position += i*Vector2(tile_size*(width),tile_size*(height))  #offset by cell position offset
			temp.position += Vector2(0,HsizeCell/2)+Vector2(0,tile_size*offset/2) #since we are in a function that places red boxes (which are always to the right of the cell, we offset by the room/2 + offset/2
			
			for BlockY in offset:
				$Walls.set_cell((i.x * width + i.x * offset) + (width/2+path_width/2), (i.y * height + i.y * offset) + (height+BlockY),0)
				$Walls.set_cell((i.x * width + i.x * offset) + (width/2-path_width/2 -1), (i.y * height + i.y * offset) + (height+BlockY),0)
			#room wall removal
			for BlockY in path_width:
				$Walls.set_cell( (i.x * width + i.x * offset) + (width/2-path_width/2) + BlockY,(i.y * height + i.y * offset) + (height)-1,1)
			for BlockY in path_width:
				$Walls.set_cell((i.x * height + i.x * offset) + (width/2-path_width/2) + BlockY, (i.y * height + i.y * offset) + (height+offset),1)
			#background filler
			for BlockX in path_width:
				for BlockY in offset + 2:
					$Background.set_cell((i.x * width + i.x * offset) + (width/2-path_width/2 + BlockX), (i.y * height + i.y * offset) + (height) + BlockY -1,2)
	post_gen()

func post_gen():
	var connection_tiles = $Walls.get_used_cells_by_id(1)
	for tile in connection_tiles:
		$Walls.set_cellv(tile,-1)
	var bg_tiles = $Background.get_used_cells_by_id(2)
	for tile in bg_tiles:
		if (wrapi(int(tile.x),0, 10) >= 5 and wrapi(int(tile.y),0, 10) < 5) or (wrapi(int(tile.x),0, 10) < 5 and wrapi(int(tile.y),0, 10) >= 5):
			$Background.set_cellv(tile,3)

func room_entered(area,room_area):
	if area.get_parent().is_in_group("Player") and room_area.triggered == false:
		room_area.triggered = true
		var i = room_area.room_pos
		for BlockX in width:
			$Walls.set_cell(((i.x * width) + (i.x * offset)) + BlockX,(i.y * height) + (i.y * offset),0)
			$Walls.set_cell(((i.x * width) + (i.x * offset)) + BlockX,(i.y * height) + (i.y * offset) + height-1,0)
		for BlockY in height:
			$Walls.set_cell((i.x * width) + (i.x * offset),(i.y * height) + (i.y * offset) + BlockY,0)
			$Walls.set_cell((i.x * width) + (i.x * offset) + width-1,(i.y * height) + (i.y * offset) + BlockY,0)
		room_area.get_node("SpawnTimer").wait_time = RNG.randf_range(min_spawn_time,max_spawn_time)
		room_area.get_node("SpawnTimer").start()
