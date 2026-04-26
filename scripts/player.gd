class_name Player
extends Resource


@export var name: String = ""
@export var wins: int = 0
@export var points: int = 0
## {station: round number} - used to track if played at special station and to sort in KO brackets
@export var played_at: Dictionary[Station, int] = {}
@export var played_at_special_station: bool = false
## {round number: placemnent} - used to ensure score is only updated once 
@export var placement_in_round: Dictionary[int, int]
## String should be player.name
@export var played_against: Dictionary[String, bool] = {} # String is Player Name


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
	var current_round = Global.tournament.rounds.size()
	if placement_in_round.has(current_round):
		if placement == placement_in_round[current_round]:
			var warning = "%s has already recieved a score in round: %d" % [name, current_round]
			#push_warning(warning)
			return warning
	#if placement <= float(match_size) / 2:
		#wins += 1
	if placement == 1:
		wins += 1
	points += match_size - placement
	
	for player in finished_match.players:
		if not player == self:
			played_against[player.name] = true
	
	played_at[finished_match.station] = current_round
	if finished_match.station.is_special_station:
		played_at_special_station = true
	
	placement_in_round[current_round] = placement
	return "OK"


func undo_score_update(unfinished_match: Match) -> String:
	if not played_at.has(unfinished_match.station):
		var warning = "%s has not played in the given match: %s" % [name, str(unfinished_match)]
		#push_warning(warning)
		return warning
	if not (self in unfinished_match.result and self in unfinished_match.players):
		var warning = "%s was not in the given match: %s" % [name, str(unfinished_match)]
		push_warning(warning)
		return warning
	var placement: int = unfinished_match.result[self]
	var match_size: int = unfinished_match.players.size()
	var current_round = Global.tournament.rounds.size()
	placement_in_round.erase(current_round)
	#if placement <= float(match_size) / 2:
		#wins += 1
	if placement == 1:
		wins -= 1
	points -= match_size - placement
	
	for player in unfinished_match.players:
		if not player == self:
			played_against.erase(player.name)
	
	played_at.erase(unfinished_match.station)
	for station in played_at.keys():
		if station.is_special_station:
			played_at_special_station = true
			break
		else:
			played_at_special_station = false
	
	return "OK"
