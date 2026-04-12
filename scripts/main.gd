extends Node


func _ready() -> void:
	var test_player: Player = Player.new()
	if ResourceSaver.save(test_player, "res://resources/test_player.res") == OK:
		print("Created new player")
	else:
		print("failed to create new player")
