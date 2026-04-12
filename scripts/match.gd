class_name Match
extends Resource


@export var players: Array[Player] = []
@export var station: Station  
@export var result: Dictionary[Player, int]


func update_result(player_in_match: Player, placement: int) -> void:
	var match_size: int = Global.tournament_settings.match_size
	if placement > match_size:
		push_warning(
			"Placement (%d) cannot be higher than the match size (%d)" % [placement, match_size]
			)
		return
	var updated_result = result.duplicate_deep()
	for player in players:
		if not player in updated_result:
			updated_result[player] = 0
	if player_in_match in updated_result:
		updated_result[player_in_match] = placement
	else:
		push_warning("%s this player is not in this match" % player_in_match.name)
	result = updated_result
