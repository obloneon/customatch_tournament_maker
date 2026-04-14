class_name SwissRoundSimulation
extends Node


@export_category("Simulation Parameters")
@export var number_of_simulation_runs: int = 1
@export var number_of_rounds: int = 1
@export var match_size: int =  4
@export var player_count: int = 48
@export var station_count: int = 6
@export var special_stations: int = 2
@export_category("Print Settings")
@export var print_swiss_rounds: bool = true
@export var print_player_wins: bool = true
@export var print_player_points: bool = true
@export var print_player_played_at_special: bool = true


func _ready() -> void:
	for i in range(number_of_simulation_runs):
		_simulate_swiss_rounds()


func _simulate_swiss_rounds() -> Array[SwissRound]:
	var swiss_rounds: Array[SwissRound] = []
	var players: Array[Player] = []
	for i in range(player_count):
		var player = Player.new()
		if i < 9:
			player.name = "player 0" + str(i + 1)
		else:
			player.name = "player " + str(i + 1)
		# Ensures properties dont get reused between runs
		player.wins = 0
		player.points = 0
		player.played_at_special_station = false
		player.played_against.clear()
		players.append(player)
	for i in range(number_of_rounds):
		var current_round := SwissRound.new(match_size, station_count, special_stations)
		current_round.swiss_round_number = i + 1
		current_round.matches = current_round.assign_players_to_matches(players)
		#var players_to_update: Array = []  
		var players_for_next_round: Array[Player] = []
		for match_res in current_round.matches:
			match_res.players.shuffle() # to simulate ramdom match winners
			var match_result: Dictionary[Player, int] = {} 
			for j in range(match_res.players.size()):
				var player_in_match := match_res.players[j]
				var placement: int = j + 1
				match_result[player_in_match] = placement
			var error = match_res.assign_result(match_result)
			if not error == "OK":
				push_warning(error)
			for player in match_res.players:
				player.update_score(match_res)
				players_for_next_round.append(player)
		swiss_rounds.append(current_round)
		players = players_for_next_round.duplicate()
		_print_swiss_round(current_round)
	return swiss_rounds


func _print_swiss_round(swiss_round: SwissRound) -> void:
	if not print_swiss_rounds:
		return
	var round_seperator := "========================================"
	var match_seperator := "----------------------------------------"
	print(round_seperator)
	print("Swiss Round Nr. " + str(swiss_round.swiss_round_number))
	for match_res in swiss_round.matches:
		print(match_seperator)
		if match_res.station.is_special_station:
			print("Match at special station %d:" % match_res.station.number)
		else:
			print("Match at station %d:" % match_res.station.number)
		var player_result_header: String = "	Name      | Placement"
		if print_player_wins:
			player_result_header += " | Wins"
		if print_player_points:
			player_result_header += " | Points"
		if print_player_played_at_special:
			player_result_header += " | Played at Special"
		print(player_result_header)
		for player: Player in match_res.result.keys():
			var player_result_template: String = "	%s |         %s"
			var string_var_array := []
			string_var_array.append(player.name)
			string_var_array.append(str(match_res.result[player]))
			if print_player_wins:
				player_result_template += " |    %s"
				string_var_array.append(str(player.wins))
			if print_player_points:
				player_result_template += " |      %s"
				string_var_array.append(str(player.points))
			if print_player_played_at_special:
				player_result_template += " | %s"
				string_var_array.append(str(player.played_at_special_station))
			print(player_result_template % string_var_array)
