class_name Match
extends Resource
## Only assign results with the [method Match.assign_result] function, to ensure 
## that the assigned result is valid.




@export var players: Array[Player] = []
@export var station: Station  
@export var result: Dictionary[Player, int]


## Validates result before assignment. 
## Returns "OK" if assignment was successfull else returns an error message
func assign_result(new_result: Dictionary[Player, int]) -> String:
	var error = _validate_result(new_result)
	if error == "OK":
		result = new_result.duplicate()

		return "OK"
	else:
		return "Result assignment failed. Error: " + error


## Returns "OK" if result is valid else returns an error message
func _validate_result(new_result: Dictionary[Player, int]) -> String:
	var placements: Array[int] = []
	if new_result.keys().size() != players.size():
		var error_message = (
			"The result has not the right amount of players. 
			Required: %d, Is: %d" % [players.size(), new_result.keys().size()]
		)
		push_warning(error_message)
		return error_message
	for player in new_result.keys():
		if not players.has(player):
			var error_message = (
				"The result does contain a player that was not in the match: 
				%s" % player.name
			)
			push_warning(error_message)
			return error_message
		else:
			var placement = new_result[player]
			if placement < 1 or placement > players.size():
				var error_message = (
					"Placement of %s is %d but must be between %d and %d" % [
						player.name, 
						placement, 
						1, 
						players.size()
					]
				)
				push_warning(error_message)
				return error_message
			else:
				if placement in placements:
					var error_message = (
						"Placement %d was already assigned" % [
							placement
						]
					)
					push_warning(error_message)
					return error_message
				placements.append(placement)
	return "OK"
