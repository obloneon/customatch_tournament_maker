class_name HelperFunctions
extends Object
## General functions not included by Godot that can be helpfull in many places
##
## It is not intended to instatiate or extend this class. 


static func calculate_average_opponent_points(player: Player) -> float:
	if Global.tournament.rounds.is_empty():
		#push_error("No rounds recorded. Cannot calculate")
		return 0.0
	var current_round = Global.tournament.rounds[Global.tournament.rounds.size()]
	var current_players = current_round.get_players()
	var opponents: Array[Player] = []
	for player_name in player.played_against.keys():
		var found_player
		for player_res in current_players:
			if player_name == player_res.name:
				found_player = player_res
				break
		if found_player != null:
			opponents.append(found_player)
	var opponents_points: float = 0
	for opponent in opponents:
		opponents_points += opponent.points
	return opponents_points / opponents.size()


func _find_player_by_name(players: Array[Player], name: String) -> Variant:
		for player_res in players:
			if name == player_res.name:
				return player_res
		return null

## Custom comparator to use in Array.sort_custom(). Sorts descending depending
## on the sort by property, and then uses the other as a tiebreaker.
static func compare_players(a, b) -> bool:
	var primary_sorting_criteria: TournamentSettings.SortingCriteria
	if Global.tournament.settings == null:
		push_error("Cant read sorting criteria. Fall back to primary = points")
		primary_sorting_criteria = TournamentSettings.SortingCriteria.POINTS
	else:
		primary_sorting_criteria = Global.tournament.settings.primary_sorting_criteria
	
	if primary_sorting_criteria == TournamentSettings.SortingCriteria.POINTS:
		if a.points == b.points:
			if a.wins == b.wins:
				return calculate_average_opponent_points(a) > calculate_average_opponent_points(b)
			return a.wins > b.wins
		return a.points > b.points
	else:
		if a.wins == b.wins:
			if a.points == b.points:
				return calculate_average_opponent_points(a) > calculate_average_opponent_points(b)
			return a.points > b.points
		return a.wins > b.wins


## Removes and returns the element of the array at index position. 
## If negative, position is considered relative to the end of the array.[br]
## Returns [code]null[/code] if the array is empty. 
## If position is out of bounds, an error message is also generated.[br]
## [br]
## [b]Note:[/b] This is an O(1) [method Array.pop_at] that does not preserve element order.
static func swap_pop(array: Array, idx: int) -> Variant:
	if array.size() == 0:
		return null
	if idx < 0:
		idx += array.size()
	if idx < 0 or idx >= array.size():
		push_error("Index is out of bounds")
		return null
	var removed_element = array[idx]
	if idx != array.size() - 1:
		array[idx] = array[-1]
	array.pop_back()
	return removed_element
