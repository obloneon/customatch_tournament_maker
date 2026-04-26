class_name TournamentSettings
extends Resource


enum SortingCriteria {
	POINTS,
	WINS,
}


## Match size of the tournament. Cannot be lower than 2.
@export var match_size: int = 2:
	set(value):
		match_size = max(value, 2)
## Amount of stations where matches happen at the tournament. Cannot be lower than 1.
@export var station_count: int = 1:
	set(value):
		station_count = max(value, 1)
## Stations that have a stand out feature
@export var special_stations: int = 0:
	set(value):
		if value > station_count:
			push_warning("There cannot be more special stations than total stations.")
		special_stations = clamp(value, 0, station_count)
## Description of the special station. This will be shown next to the stations 
## number if it is a special station.
@export var special_station_name: String = "Special":
	set(value):
		if value == "":
			return
		special_station_name = value
@export var primary_sorting_criteria: SortingCriteria = SortingCriteria.POINTS
@export var ko_advancement_limit: int = 2:
	set(value):
		value = clamp(value, 1, match_size - 1)
		ko_advancement_limit = value


## Returns whether settings were changed as a boolean value
func update(setting_dict: Dictionary[String, Variant]) -> bool:
	var properties: Dictionary[String, int]= {}
	for property in self.get_property_list():
		properties[property["name"]] = property["type"]
	var settings_changed := false
	for setting in setting_dict.keys():
		if setting in properties:
			var value: Variant = setting_dict[setting]
			var property_type = properties[setting]
			if typeof(value) == property_type:
				self.set(setting, value)
				settings_changed = true
			else:
				push_error(
					"Cannot assign %s with value: %s to a property with type: %s " % [
						setting, str(value), str(property_type)
					]
				)
		else:
			push_warning("Tried to change setting %s but it does not exist" % [setting])
	return settings_changed
