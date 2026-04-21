class_name UISettings
extends Resource


const SETTINGS_PATH: String = "user://settings/ui_settings.tres"

@export var font_size: int = 32:
	set(value):
		font_size = max(1, value)
## How many characters of a players name will be displayed. This affects the size 
## of the match displays. It it recomended to keep this low if the player count is high.
@export var player_name_max_characters: int = 18:
	set(value):
		player_name_max_characters = max(1, value)


## Returns a warning if it fails else returns OK
func save() -> String:
	var error = ResourceSaver.save(self, SETTINGS_PATH)
	if error == OK:
		print("Successfully saved UI settings to " + SETTINGS_PATH)
		return "OK"
	else:
		var error_message = "Failed to save UI settings. Error:" + str(error)
		push_warning(error_message)
		return error_message


static func load_or_create() -> UISettings:
	var res: UISettings
	if FileAccess.file_exists(SETTINGS_PATH):
		res = load(SETTINGS_PATH) as UISettings
	else:
		res = UISettings.new()
		var settings_dir_path := SETTINGS_PATH.replacen("ui_settings.tres", "")
		if not DirAccess.dir_exists_absolute(settings_dir_path):
			var error = DirAccess.make_dir_absolute(settings_dir_path)
			if error != OK:
				push_error(error)
		res.save()
	return res
