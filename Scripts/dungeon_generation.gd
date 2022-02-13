extends Node

var room = preload("res://Assets/Room.tscn")

var min_number_rooms = 10
var max_number_rooms = 15

var generation_chance = 20

func generate(room_seed):
	var boss_room_generated = false
	randomize()
	seed(floor(rand_range(1,100000000)))
	var dungeon = {}
	var size = floor(rand_range(min_number_rooms, max_number_rooms))
	
	dungeon[Vector2(0,0)] = room.instance()
	size -= 1
	dungeon[Vector2(0,0)].discovered = true
	dungeon[Vector2(0,0)].room_type = "home"
	
	while(size > 0):
		for i in dungeon.keys():
			if(rand_range(0,100) < generation_chance):
				var direction = rand_range(0,4)
				if(direction < 1):
					var new_room_position = i + Vector2(1, 0)
					if(!dungeon.has(new_room_position)):
						dungeon[new_room_position] = room.instance()
						size -= 1
					if(dungeon.get(i).connected_rooms.get(Vector2(1, 0)) == null):
						connect_rooms(dungeon.get(i), dungeon.get(new_room_position), Vector2(1, 0))
				elif(direction < 2):
					var new_room_position = i + Vector2(-1, 0)
					if(!dungeon.has(new_room_position)):
						dungeon[new_room_position] = room.instance()
						size -= 1
					if(dungeon.get(i).connected_rooms.get(Vector2(-1, 0)) == null):
						connect_rooms(dungeon.get(i), dungeon.get(new_room_position), Vector2(-1, 0))
				elif(direction < 3):
					var new_room_position = i + Vector2(0, 1)
					if(!dungeon.has(new_room_position)):
						dungeon[new_room_position] = room.instance()
						size -= 1
					if(dungeon.get(i).connected_rooms.get(Vector2(0, 1)) == null):
						connect_rooms(dungeon.get(i), dungeon.get(new_room_position), Vector2(0, 1))
				elif(direction < 4):
					var new_room_position = i + Vector2(0, -1)
					if(!dungeon.has(new_room_position)):
						dungeon[new_room_position] = room.instance()
						size -= 1
					if(dungeon.get(i).connected_rooms.get(Vector2(0, -1)) == null):
						connect_rooms(dungeon.get(i), dungeon.get(new_room_position), Vector2(0, -1))
#	while(!is_interesting(dungeon)):
#		for i in dungeon.keys():
#			dungeon.get(i).queue_free()
#		var sed = room_seed * rand_range(-1,1) + rand_range(-100,100)
#		dungeon = generate(sed)
	if boss_room_generated == false:
		for l in dungeon.keys():
			if dungeon.get(l).number_of_connections == 1 and l != Vector2(0,0):
				dungeon.get(l).room_type = "boss"
				boss_room_generated = true
				break
		if boss_room_generated == false:
			for l in dungeon.keys():
				if dungeon.get(l).number_of_connections == 2 and l != Vector2(0,0):
					dungeon.get(l).room_type = "boss"
					boss_room_generated = true
					break
	return dungeon

func connect_rooms(room1, room2, direction):
	room1.connected_rooms[direction] = room2
	room2.connected_rooms[-direction] = room1
	room1.number_of_connections += 1
	room2.number_of_connections += 1

func is_interesting(dungeon):
	var room_with_three = 0
	for i in dungeon.keys():
		if(dungeon.get(i).number_of_connections >= 3):
			room_with_three += 1
	return room_with_three >= 2
