class_name SwissRound
extends TournamentRound


func _init() -> void:
	round_type = RoundType.SWISS


## Tries to fill all players into matches based on the suitability score calculation. 
func assign_players_to_matches(players: Array[Player]) -> Array[Match]:
	if players.size() < 2:
		push_error(
			"Player assignment failed: Player list contains less than 2 players"
		)
		return []
			 
	var new_matches: Array[Match] = _create_matches(players.size())
	var total_players = players.size()
	var total_assigned_players: int = 0
	if round_number == 1:
		for new_match in new_matches:
			var needed_players: int = match_size
			while players.size() > 0 and needed_players > 0:
				new_match.players.append(players.pop_back())
				total_assigned_players += 1
				needed_players -= 1
	else:
		for new_match in new_matches:
			var needed_players: int = match_size
			while players.size() > 0 and needed_players > 0:
				var suitable_player_idx = _find_suitable_player_index(new_match, players)
				new_match.players.append(HelperFunctions.swap_pop(players, suitable_player_idx))
				total_assigned_players += 1
				needed_players -= 1
	if total_assigned_players != total_players:
		push_error("Player assignment failed: Not all players were assigned")
		return []
	return new_matches


## @experimental: This creates more matches than needed to fit all players because
## this keeps player pools from mixing.
func _assign_players_to_matches_without_crossing_pools(players: Array[Player]) -> Array[Match]:
	if players.size() < 2:
		push_error("Player assignment failed: Player list contains less than 2 players")
		return []
	var empty_matches: Array[Match] = _create_matches(players.size())
	var filled_matches: Array[Match] = []
	var balanced_matches:Array[Match] = []
	var player_pools: Dictionary[int, Array] = {} # Array is Array[Player]
	# pool creation
	if round_number == 1:
		player_pools[0] = players.duplicate_deep()
	else:
		for player in players:
			if player_pools.has(player.wins):
				player_pools[player.wins].append(player)
			else:
				player_pools[player.wins] = [player]
	# match filling
	for key in player_pools.keys():
		var player_pool = player_pools[key]
		# If not all player fit into the original matches add further ones too keep matches from crossing pools
		if balanced_matches.size() == ceil(float(players.size()) / match_size) and empty_matches.is_empty():
				var total_players: int = 0
				for balanced_match in balanced_matches:
					total_players += balanced_match.players.size()
				var missing_players: int = players.size() - total_players 
				if missing_players != 0:
					empty_matches.append_array(_create_matches(missing_players))
		while empty_matches.size() > 0 and player_pool.size() > 0:
			var empty_match = empty_matches[0]
			var fill_range: int = min(match_size, player_pool.size())
			for i in range(fill_range):
				var fitting_player
				if round_number > 1:
					var fitting_index: int = _find_suitable_player_index(empty_match, player_pool)
					fitting_player = HelperFunctions.swap_pop(player_pool, fitting_index)
					if fitting_player == null:
						push_error(
							"Player assignment failed: No fitting player in 
							bounds of current player pool: " + player_pool
							)
						return []
				else:
					fitting_player = player_pool.pop_front()
				empty_match.players.append(fitting_player)
			var filled_match = empty_matches.pop_front() #HelperFunctions.swap_pop(empty_matches, 0)
			filled_matches.append(filled_match)
		if filled_matches.size() == 0:
			push_warning("Player assignment failed: No matches were filled")
			return []
		# match balancing
		if match_size > 2:
			var last_match = filled_matches[-1]
			var last_match_station_is_special = last_match.station.is_special_station
			var missing_players: int = match_size - last_match.players.size()
			while missing_players > 1:
				var found_player := false
				# First pass tries to pull from matches with the same station type.
				for i in range(filled_matches.size() - 1):
					var current_match = filled_matches[i]
					var match_station_is_special = current_match.station.is_special_station
					if current_match.players.size() == match_size:
						if match_station_is_special == last_match_station_is_special:
							last_match.players.append(current_match.players.pop_back())
							missing_players = match_size - last_match.players.size()
							found_player = true
							break
				if found_player:
					continue
				# Second pass tries to balance while ensuring that players that
				# havent played at a special station remain at/ get assigned to
				# a special staition.
				for i in range(filled_matches.size() - 1):
					var current_match = filled_matches[i]
					if current_match.players.size() == match_size:
						if last_match_station_is_special:
							for j in range(current_match.players.size()):
									if not current_match.players[j].played_at_special_station:
										last_match.players.append(current_match.players.pop_at(j))
										missing_players = match_size - last_match.players.size()
										found_player = true
										break
						elif current_match.station.is_special_station:
							for j in range(current_match.players.size()):
									if current_match.players[j].played_at_special_station:
										last_match.players.append(current_match.players.pop_at(j))
										missing_players = match_size - last_match.players.size()
										found_player = true
										break
				if found_player:
					continue
				# Third pass pulls a player if the match is a full match without other checks.
				for i in range(filled_matches.size() - 1):
					var current_match = filled_matches[i]
					if current_match.players.size() == match_size:
						last_match.players.append(current_match.players.pop_back())
						missing_players = match_size - last_match.players.size()
						found_player = true
						break
				if not found_player:
					break
		balanced_matches.append_array(filled_matches)
		filled_matches.clear()
	# check result
	var total_assigned_players: int = 0
	for balanced_match in balanced_matches:
		total_assigned_players += balanced_match.players.size()
	if total_assigned_players != players.size():
		push_error("Player assignment failed: Not all players were assigned")
		return []
	
	return balanced_matches


func _find_suitable_player_index(current_match: Match, player_pool: Array) -> int:
	var best_idx := -1
	var best_score := -1
	for i in range(player_pool.size()):
		var player = player_pool[i]
		var score := _calculate_suitability(player, current_match)
		if score > best_score:
			best_score = score
			best_idx = i
	return best_idx


## Returns a score that represents how fitting a player is to the applied criteria.
## Higher Score == Higher suitability
func _calculate_suitability(player: Player, current_match: Match) -> int:
	var score: int = 0
	var players_in_match_count: int = current_match.players.size()
	# prefer players who haven't played at a special station if match is at a special station
	if current_match.station.is_special_station:
		if not player.played_at_special_station:
			score += 16 + players_in_match_count
	# penalize players who haven't played at a special station if match is not at a special station
	if not current_match.station.is_special_station:
		if not player.played_at_special_station:
			score -= 15 + players_in_match_count
	# penalize number of conflicts with current players
	# prefer players with the same or similar points
	var conflicts: int = 0
	var point_differential: int = 0
	for match_player in current_match.players:
		point_differential += abs(player.points - match_player.points)
		if player.played_against.has(match_player.name):
			conflicts += 1
	score += max(0, 10 + players_in_match_count - conflicts)
	score += max(0, 5 + players_in_match_count - point_differential)
	return score
