class_name TournamentRoundUI
extends PanelContainer


const _MATCH_CONTAINER_UID := "uid://dr0etkq7p23v4"
const _MATCH_GROUP_UID := "uid://cnw68ot40x1pl"

@export var round_res: TournamentRound

var grid_column_count: int:
	set(value):
		value = max(1, value)
		grid_column_count = value
		for match_group in match_group_container.get_children():
			match_group.matches_grid.columns = grid_column_count
var grid_h_seperation: int:
	set(value):
		value = max(0, value)
		grid_h_seperation = value
		for match_group in match_group_container.get_children():
			match_group.matches_grid.h_seperation = grid_h_seperation
var grid_v_seperation: int:
	set(value):
		value = max(0, value)
		grid_v_seperation = value
		for match_group in match_group_container.get_children():
			match_group.matches_grid.v_seperation = grid_v_seperation
var _finished_matches: Dictionary[Match, bool] = {}

@onready var round_content_container: VBoxContainer = $RoundContentContainer
@onready var back_button: Button = $RoundContentContainer/HeaderPanelContainer/RoundHeader/BackButton
@onready var round_label: Label = $RoundContentContainer/HeaderPanelContainer/RoundHeader/RoundLabel
@onready var settings_button: Button = $RoundContentContainer/HeaderPanelContainer/RoundHeader/SettingsButton
@onready var finished_matches_label: Label = $RoundContentContainer/HeaderPanelContainer/RoundHeader/FinishedMatchesLabel
@onready var next_button: Button = $RoundContentContainer/HeaderPanelContainer/RoundHeader/NextButton
@onready var match_group_container: VFlowContainer = $RoundContentContainer/ScrollContainer/MatchGroupContainer
@onready var next_action_panel_container: PanelContainer = $NextActionPanelContainer
@onready var close_button: Button = $NextActionPanelContainer/VBoxContainer/CloseButton
@onready var new_round_button: Button = $NextActionPanelContainer/VBoxContainer/ActionSelctionContainer/NewRoundButton
@onready var results_button: Button = $NextActionPanelContainer/VBoxContainer/ActionSelctionContainer/ResultsButton


func _ready() -> void:
	# connect signals of internal buttons
	if not next_button.button_up.is_connected(_set_next_action_selection_visible):
		next_button.button_up.connect(_set_next_action_selection_visible.bind(true))
	if not close_button.button_up.is_connected(_set_next_action_selection_visible):
		close_button.button_up.connect(_set_next_action_selection_visible.bind(false))


func update() -> void:
	if not round_res:
		push_error("No swiss round resource assigned")
		return
	# Ensure the correct elements are visible at ready
	_finished_matches.clear()
	_set_next_round_button_visiblity()
	_set_next_action_selection_visible(false)
	# Set the right text for dynamic labels
	round_label.text = "Round %d"  % round_res.round_number
	finished_matches_label.text = "Finished Matches: %d / %d" % [
		_finished_matches.size(), round_res.matches.size()
	]
	# Remove old match groups
	while match_group_container.get_child_count() > 0:
		var child = match_group_container.get_child(0)
		match_group_container.remove_child(child)
		child.queue_free()
	# Sort matches into match groups so that no station has more than one match
	# at the same time
	var match_groups: Dictionary[int, Array] = {} # Array[Match]
	for match_res in round_res.matches:
		var station = match_res.station
		if match_groups.has(station.group):
			var group = match_groups[station.group]
			for other_match in group:
				if station.number == other_match.station.number:
					push_error("Station number shouldnt be assigned more then once per group")
			group.append(match_res)
		else:
			match_groups[station.group] = [match_res]
		
	# Use the match groups dictionary to build match groups and add them to the 
	# RoundContainer
	var match_group := load(_MATCH_GROUP_UID)
	var match_container := load(_MATCH_CONTAINER_UID)
	for group_number in match_groups.keys():
		var match_group_instance := match_group.instantiate() as MatchGroup
		match_group_container.add_child(match_group_instance)
		match_group_instance.group_number = group_number
		for match_res in match_groups[group_number]:
			var match_container_instance = match_container.instantiate() as MatchContainer
			match_group_instance.matches_grid.add_child(match_container_instance)
			match_container_instance.match_res = match_res
			match_container_instance.result_assigned.connect(_add_to_finished_matches)
			match_container_instance.invalid_result_entered.connect(_remove_from_finished_matches)
			match_container_instance.update()


func _add_to_finished_matches(match_res: Match) -> void:
	_finished_matches[match_res] = true
	for player in match_res.players:
		player.update_score(match_res)
	Global.tournament.save()
	finished_matches_label.text = "Finished Matches: %d / %d" % [
		_finished_matches.size(), round_res.matches.size()
	]
	_set_next_round_button_visiblity()


func _remove_from_finished_matches(match_res: Match) -> void:
	_finished_matches.erase(match_res)
	for player in match_res.players:
		player.undo_score_update(match_res)
	Global.tournament.save()
	finished_matches_label.text = "Finished Matches: %d / %d" % [
		_finished_matches.size(), round_res.matches.size()
	]


func _set_next_round_button_visiblity() -> void:
		var complete: bool = _finished_matches.size() == round_res.matches.size()
		finished_matches_label.visible = not complete
		next_button.visible = complete


func _set_next_action_selection_visible(make_visible: bool) -> void:
	round_content_container.visible = not make_visible
	next_action_panel_container.visible = make_visible
