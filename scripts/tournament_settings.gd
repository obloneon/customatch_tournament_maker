class_name TournamentSettings
extends Resource


const SETTINGS_PATH: String = "user://settings/tournament_settings.tres"

## Amount of stations where matches happen at the tournament. Cannot be lower than 1.
@export var station_count: int = 1:
	set(value):
		station_count = max(value, 1)
## Match size of the tournament. Cannot be lower than 2.
@export var match_size: int = 4:
	set(value):
		match_size = max(value, 2)
## Stations that have a stand out feature
@export var special_stations: int = 0:
	set(value):
		if value > station_count:
			push_warning("There cannot be more special stations than total stations.")
		special_stations = clamp(value, 0, station_count)
## Description of the special station. This will be shown next to the stations 
## number if it is a special station.
@export var special_station_label: String = "Special"

## Returns a warning if it fails else returns OK
func save() -> String:
	var error = ResourceSaver.save(self, SETTINGS_PATH)
	if error == OK:
		print("Successfully saved tournament settings to " + SETTINGS_PATH)
		return "OK"
	else:
		var error_message = "Failed to save tournament settings. Error:" + str(error)
		push_warning(error_message)
		return error_message


static func load_or_create() -> TournamentSettings:
	var res: TournamentSettings
	if FileAccess.file_exists(SETTINGS_PATH):
		res = load(SETTINGS_PATH) as TournamentSettings
	else:
		res = TournamentSettings.new()
	return res
