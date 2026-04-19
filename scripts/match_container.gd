class_name MatchContainer
extends PanelContainer


signal result_assigned(match_res: Match)
signal invalid_result_entered(match_res: Match)

const _MATCH_SLOT_UID := "uid://dlhq64kpm75kn"

## The [Match] resource displayed by this match container
@export var match_res: Match

var _entered_match_result: Dictionary[Player, int] = {}
var _player_count: int

@onready var match_label: Label = $VBoxContainer/PanelContainerLabel/MatchLabel
@onready var match_slot_container: HFlowContainer = $VBoxContainer/PanelContainerSlots/MatchSlotContainer


func update() -> void:
	if match_res == null:
		push_error("no match resource assigned")
		return
	# MatchLabelSetup
	var station: Station = match_res.station
	if station:
		var special_station_text: String = ""
		if station.is_special_station:
			special_station_text = Global.tournament_settings.special_station_label + " "
		match_label.text = "%sStation %d" % [special_station_text, station.number] 
	# MatchSlotContainer setup
	# Remove the old match slots
	while match_slot_container.get_child_count() > 0:
		var child = match_slot_container.get_child(0)
		match_slot_container.remove_child(child)
		child.queue_free()
	# Add the new slots
	_player_count = match_res.players.size()
	var match_slot := load(_MATCH_SLOT_UID)
	for player in match_res.players:
		var match_slot_instance := match_slot.instantiate() as MatchSlot
		match_slot_container.add_child(match_slot_instance)
		match_slot_instance.player_res = player
		match_slot_instance.player_label.text = player.name
		var placement_input: LineEdit = match_slot_instance.placement_input
		placement_input.text_changed.connect(set_placement.bind(match_slot_instance))
		placement_input.max_length = len(str(_player_count))


func set_placement(input: String, match_slot: MatchSlot) -> void:
	if match_res == null:
		input = ""
	if not input.is_valid_int():
		input = ""
		_entered_match_result.erase(match_slot.player_res)
		invalid_result_entered.emit(match_res)
	else:
		var input_value: int = int(input)
		input_value = clamp(input_value, 0, _player_count)
		input = str(input_value)
		_entered_match_result[match_slot.player_res] = input_value
		if input_value == 0:
			_entered_match_result.erase(match_slot.player_res)
	match_slot.placement_input.text = input
	
	if _entered_match_result.keys().size() == _player_count:
		var error = match_res.assign_result(_entered_match_result)
		if error != "OK":
			invalid_result_entered.emit(match_res)
			push_warning(error)
			return # implement error label
		result_assigned.emit(match_res)
