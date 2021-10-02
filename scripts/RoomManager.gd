extends Node

var player
var current_room
var current_camera: Camera2D

func register_player(value):
	player = value

func set_room(value):
	current_room = value
	set_camera(current_room.get_camera())

func set_camera(value):
	if current_camera:
		current_camera.current = false
	
	current_camera = value
	current_camera.current = true
	
	if current_camera.has_method("set_target"):
		current_camera.set_target(player)
