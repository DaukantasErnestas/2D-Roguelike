extends Node2D

var room_type = "Basic"
var discovered = false

var connected_rooms = {
	Vector2(1, 0): null,
	Vector2(-1, 0): null,
	Vector2(0, 1): null,
	Vector2(0, -1): null
}

var number_of_connections = 0
