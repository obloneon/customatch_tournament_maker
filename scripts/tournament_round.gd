@abstract
class_name TournamentRound
extends Resource


enum RoundType {
	KO,
	SWISS,
}

@export var round_type: RoundType
@export var round_number: int = 1
@export var matches: Array[Match]
@export var match_size: int
@export var station_count: int
@export var special_stations_count: int 


@abstract
func assign_players_to_matches(players: Array[Player]) -> Array[Match]


func _create_matches(number_of_players: int) -> Array[Match]:
	var created_matches: Array[Match] = []
	var needed_matches: int = ceil(float(number_of_players) / match_size)
	var stations_by_group: Dictionary[int, Array] = {} # Array[Station]
	for i in range(needed_matches):
		var new_match = Match.new()
		var station = Station.new()
		# Ensures that stations get assigned corectly even if station count < needed matches
		station.number = (i % station_count) + 1
		if station.number <= special_stations_count:
			station.is_special_station = true
		new_match.station = station
		# Sets the group of the station
		var found_group = null
		for group in stations_by_group.keys():
			var group_has_number := false
			for other_station in stations_by_group[group]:
				if station.number == other_station.number:
					group_has_number = true
					break
			if not group_has_number:
				found_group = group
				break
		if found_group != null:
			stations_by_group[found_group].append(station)
			station.group = found_group
		else:
			var new_group = stations_by_group.size() + 1
			stations_by_group[new_group] = [station]
			station.group = new_group
		created_matches.append(new_match)
	return created_matches


## Returns the [Player]s in this Round. If non are found then an empty Array is
## returned instead.
func get_players() -> Array[Player]:
	var players_array: Array[Player] = []
	for match_res in matches:
		if match_res == null:
			continue
		for player in match_res.players:
			if player != null:
				players_array.append(player)
	return players_array


## Returns an error if it fails else returns OK
func save_to_tournament(overwrite: bool = false) -> Error:
	if Global.tournament == null:
		return Error.ERR_UNCONFIGURED
	if Global.tournament.rounds.has(round_number) and not overwrite:
		return Error.ERR_ALREADY_EXISTS
	Global.tournament.rounds[round_number] = self
	return Global.tournament.save()


## Used after creating a new round to set the needed properties.
## Round type is set during _init.[br]
## Cannot be done in _ready or _init because of timing/ resource loading problems.
func setup_new_round(player_list: Array[Player]):
	match_size = Global.tournament.settings.match_size
	station_count = Global.tournament.settings.station_count
	special_stations_count = Global.tournament.settings.special_stations
	round_number = Global.tournament.rounds.size() + 1
	matches = assign_players_to_matches(player_list)
