class_name TournamentSettingsUIEdit
extends PanelContainer


@onready var match_size_edit: LineEdit = $TournamentSettingsContainer/MatchSizeContainer/MatchSizeEdit
@onready var station_count_edit: LineEdit = $TournamentSettingsContainer/StationCountContainer/StationCountEdit
@onready var special_stations_edit: LineEdit = $TournamentSettingsContainer/SpecialStationsContainer/SpecialStationsEdit
@onready var special_station_name_edit: LineEdit = $TournamentSettingsContainer/SpecialStationNameContainer/SpecialStationNameEdit


func _ready() -> void:
	match_size_edit.placeholder_text = str(Global.tournament_settings.match_size)
	station_count_edit.placeholder_text = str(Global.tournament_settings.station_count)
	special_stations_edit.placeholder_text = str(Global.tournament_settings.special_stations)
	special_station_name_edit.placeholder_text = str(Global.tournament_settings.special_station_name)
	
	if not match_size_edit.text_changed.is_connected(_on_match_size_edit_text_changed):
		match_size_edit.text_changed.connect(_on_match_size_edit_text_changed)
	if not station_count_edit.text_changed.is_connected(_on_station_count_edit_text_changed):
		station_count_edit.text_changed.connect(_on_station_count_edit_text_changed)
	if not special_stations_edit.text_changed.is_connected(_on_special_stations_edit_text_changed):
		special_stations_edit.text_changed.connect(_on_special_stations_edit_text_changed)


func _on_match_size_edit_text_changed(input: String) -> void:
	if not input.is_valid_int():
		match_size_edit.text = ""


func _on_station_count_edit_text_changed(input: String) -> void:
	if not input.is_valid_int():
		station_count_edit.text = ""


func _on_special_stations_edit_text_changed(input: String) -> void:
	if not input.is_valid_int():
		special_stations_edit.text = ""
