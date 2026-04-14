class_name Player
extends Resource


@export var name: String = ""
@export var wins: int = 0
@export var points: int = 0
@export var played_at_special_station: bool = false
@export var played_against: Dictionary[Player, bool] = {}

func _init() -> void:
	if name == "":
		name = "player_" + str(randi() % 1000 + 1)


## Returns a warning if it fails else returns OK
func update_score(finished_match: Match) -> String:
	if not (self in finished_match.result and self in finished_match.players):
		var warning = "%s was not in the given match: %s" % [name, str(finished_match)]
		push_warning(warning)
		return warning
	var placement: int = finished_match.result[self]
	var match_size: int = finished_match.players.size()
	
	if placement <= float(match_size) / 2:
		wins += 1
	points += match_size - placement
	
	for player in finished_match.players:
		if not player == self:
			played_against[player] = true
	
	if finished_match.station.is_special_station:
		played_at_special_station = true
	
	return "OK"


## Saves the player to the specifed path. If no path is given it will default to
## [member Resource.resource_path].[br] 
## Returns a warning if it fails else returns OK.
func save(save_path: String = "") -> String:
	if save_path == "":
		save_path = self.resource_path
	var error = ResourceSaver.save(self, save_path)
	if error == OK:
		print("Successfully saved player %s to %s" % [name, save_path])
		return "OK"
	else:
		var error_message = "Failed to save player %s to %s. Error: %s" % [name, save_path, error]
		push_warning(error_message)
		return error_message
