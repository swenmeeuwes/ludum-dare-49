extends Node2D

func _ready():
	RoomManager.set_room($Rooms/Start)

func _finish_game():
	# TODO goto outro
	pass

func _on_End_body_entered(body):
	if body.is_in_group("player"):
		_finish_game()
