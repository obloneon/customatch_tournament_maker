class_name TournamentSettingsUIEdit
extends PanelContainer


var _changes: Dictionary[String, Variant] = {}

@onready var match_size_edit: LineEdit = $TournamentSettingsContainer/MatchSizeContainer/MatchSizeEdit
@onready var station_count_edit: LineEdit = $TournamentSettingsContainer/StationCountContainer/StationCountEdit
@onready var special_stations_edit: LineEdit = $TournamentSettingsContainer/SpecialStationsContainer/SpecialStationsEdit
@onready var special_station_name_edit: LineEdit = $TournamentSettingsContainer/SpecialStationNameContainer/SpecialStationNameEdit
@onready var ko_advancement_edit: LineEdit = $TournamentSettingsContainer/KOAdvancementContainer/KOAdvancementEdit
@onready var ko_advancement_container: HBoxContainer = $TournamentSettingsContainer/KOAdvancementContainer


func _ready() -> void:
	_update_placeholder_text()
	if not match_size_edit.text_changed.is_connected(_on_match_size_edit_text_changed):
		match_size_edit.text_changed.connect(_on_match_size_edit_text_changed)
	if not station_count_edit.text_changed.is_connected(_on_station_count_edit_text_changed):
		station_count_edit.text_changed.connect(_on_station_count_edit_text_changed)
	if not special_stations_edit.text_changed.is_connected(_on_special_stations_edit_text_changed):
		special_stations_edit.text_changed.connect(_on_special_stations_edit_text_changed)
	if not special_station_name_edit.text_changed.is_connected(_on_special_station_name_edit_text_changed):
		special_station_name_edit.text_changed.connect(_on_special_station_name_edit_text_changed)
	if not ko_advancement_edit.text_changed.is_connected(_on_ko_advancement_edit_text_changed):
		ko_advancement_edit.text_changed.connect(_on_ko_advancement_edit_text_changed)


func _on_match_size_edit_text_changed(input: String) -> void:
	if not input.is_valid_int():
		match_size_edit.text = ""
		return
	var int_input = max(2, int(input))
	_changes["match_size"] = int_input
	match_size_edit.text = str(int_input)


func _on_station_count_edit_text_changed(input: String) -> void:
	if not input.is_valid_int():
		station_count_edit.text = ""
		return
	var int_input = max(1, int(input))
	_changes["station_count"] = int_input
	station_count_edit.text = str(int_input)


func _on_special_stations_edit_text_changed(input: String) -> void:
	if not input.is_valid_int():
		special_stations_edit.text = ""
		return
	var int_input = max(0, int(input))
	_changes["special_stations"] = int_input
	special_stations_edit.text = str(int_input)


func _on_special_station_name_edit_text_changed(input: String) -> void:
	_changes["special_station_name"] = input


func _on_ko_advancement_edit_text_changed(input: String) -> void:
	if not input.is_valid_int():
		special_stations_edit.text = ""
		return
	var int_input = max(1, int(input))
	_changes["ko_advancement_limit"] = int_input
	ko_advancement_edit.text = str(int_input)


func _update_placeholder_text() -> void:
	if Global.tournament == null:
		push_error("Cannot set placeholder_text: No tournament loaded")
		return
	
	match_size_edit.placeholder_text = str(
		Global.tournament.settings.match_size
	)
	station_count_edit.placeholder_text = str(
		Global.tournament.settings.station_count
	)
	special_stations_edit.placeholder_text = str(
		Global.tournament.settings.special_stations
	)
	special_station_name_edit.placeholder_text = str(
		Global.tournament.settings.special_station_name
	)
	ko_advancement_edit.placeholder_text = str(
		Global.tournament.settings.ko_advancement_limit
	)


func save_changes() -> void:
	if _changes.is_empty():
		push_warning("nothing to save")
		return
	if Global.tournament == null:
		push_error("no tournament loaded")
	if Global.tournament.settings.update(_changes):
		var error = Global.tournament.save()
		if error == OK:
			_update_placeholder_text()
		else:
			push_error("Could not save changes - %s " % error_string(error)) 
	else:
		push_error("No changes where applied")
