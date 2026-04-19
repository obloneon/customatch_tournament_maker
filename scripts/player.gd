class_name Player
extends Resource


@export var name: String = ""
@export var wins: int = 0
@export var points: int = 0
@export var played_at_special_station: bool = false
## String should be player.name
@export var played_against: Dictionary[String, bool] = {} 


func _init(player_name: String = "") -> void:
	if player_name == "":
		name = "player_" + str(randi() % 1000 + 1)
	else:
		name = player_name


## Returns a warning if it fails else returns OK
func update_score(finished_match: Match) -> String:
	if not (self in finished_match.result and self in finished_match.players):
		var warning = "%s was not in the given match: %s" % [name, str(finished_match)]
		push_warning(warning)
		return warning
	var placement: int = finished_match.result[self]
	var match_size: int = finished_match.players.size()
	
	#if placement <= float(match_size) / 2:
		#wins += 1
	if placement == 1:
		wins += 1
	points += match_size - placement
	
	for player in finished_match.players:
		if not player == self:
			played_against[player.name] = true
	
	if finished_match.station.is_special_station:
		played_at_special_station = true
	
	return "OK"
