class_name  KORound
extends TournamentRound


@export var ko_advancement_limit: int 


func _init() -> void:
	round_type = RoundType.KO


func assign_players_to_matches(players: Array[Player]) -> Array[Match]:
	if players.size() < 2:
		push_error(
			"Player assignment failed: Player list contains less than 2 players"
		)
		return []
			 
	var new_matches: Array[Match] = _create_matches(players.size())
	var total_players = players.size()
	var total_assigned_players: int = 0
	if Global.tournament.rounds.has(round_number - 1):
		var previous_round = Global.tournament.rounds[round_number - 1]
		if previous_round.round_type != RoundType.KO:
		# Sorts players and then pairs first seeds against last seeds
			players.sort_custom(HelperFunctions.compare_players)
			# how many pop_backs are done before switchin to pop front
			var pop_back_max: int = match_size - ko_advancement_limit 
			# how many pops happend since the last switch
			var pop_back_count: int = pop_back_max # to start at pop front 
			for new_match in new_matches:
				var needed_players: int = match_size
				while players.size() > 0 and needed_players > 0:
					if pop_back_count < pop_back_max:
						new_match.players.append(players.pop_back())
						pop_back_count += 1
						total_assigned_players += 1
						needed_players -= 1
					else:
						new_match.players.append(players.pop_front())
						pop_back_count = 0
						total_assigned_players += 1
						needed_players -= 1
		else:
		# Bracket logic gets applied
			# Sort players decending by the group and number of the station they
			# last played at: First rank by group and than by number.
			# If both played at the same station the player with the worse
			# placement gets sorted in first.
			players.sort_custom(
				func(a: Player, b: Player):
					var station_a
					var station_b
					for station in a.played_at.keys():
						if a.played_at[station] == previous_round.round_number:
							station_a = station
					for station in b.played_at.keys():
						if b.played_at[station] == previous_round.round_number:
							station_b = station
					if station_a == null:
						push_warning("player a has no station in the last round")
						return true
					if station_b == null:
						push_warning("player b has no station in the last round")
						return false
					if station_a.group == station_b.group:
						if station_a.number == station_b.number:
							var placement_a = a.placement_in_round[
								previous_round.round_number
							]
							var placement_b = b.placement_in_round[
								previous_round.round_number
							]
							return placement_a > placement_b
						return station_a.number > station_b.number
					return station_a.group > station_b.group
			)
			for new_match in new_matches:
				var needed_players: int = match_size
				while players.size() > 0 and needed_players > 0:
					new_match.players.append(players.pop_back())
					total_assigned_players += 1
					needed_players -= 1
	else:
	# Just assigns all players from back to front as no prior results can be used to sort
		for new_match in new_matches:
			var needed_players: int = match_size
			while players.size() > 0 and needed_players > 0:
				new_match.players.append(players.pop_back())
				total_assigned_players += 1
				needed_players -= 1
		
	if total_assigned_players != total_players:
		push_error("Player assignment failed: Not all players were assigned")
		return []
	return new_matches


## Overwrites the setup from TournamentRound to add ko_advancement_limit
func setup_new_round(player_list: Array[Player]):
	match_size = Global.tournament.settings.match_size
	station_count = Global.tournament.settings.station_count
	special_stations_count = Global.tournament.settings.special_stations
	ko_advancement_limit = Global.tournament.settings.ko_advancement_limit
	round_number = Global.tournament.rounds.size() + 1
	matches = assign_players_to_matches(player_list)
