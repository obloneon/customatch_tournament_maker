class_name Tournament
extends Resource


const SAVE_PATH: String = "user://tournament.tres"


@export var settings: TournamentSettings
@export var version := ProjectSettings.get_setting("application/config/version") as String
@export var rounds: Dictionary[int, TournamentRound] = {}


static func create_new() -> Tournament:
	var tournament = Tournament.new()
	tournament.settings = TournamentSettings.new()
	tournament.save()
	return tournament


static func load_or_create() -> Tournament:
	var tournament: Tournament
	if ResourceLoader.exists(SAVE_PATH):
		tournament = ResourceLoader.load(
			SAVE_PATH, "Tournament", ResourceLoader.CACHE_MODE_IGNORE
		)
	else:
		tournament = create_new()
	return tournament


## Returns an error if it fails else returns OK
func save() -> Error:
	var error: Error
	# Use this part if a tournament should not be directly saved into user://
	#var settings_dir_path := SAVE_PATH.replacen("tournament.tres", "")
	#if not DirAccess.dir_exists_absolute(settings_dir_path):
		#error = DirAccess.make_dir_absolute(settings_dir_path)
		#if error != OK:
			#return error
	
	error = ResourceSaver.save(self, SAVE_PATH)
	if error == OK:
		print("Successfully saved tournament to " + SAVE_PATH)
		return error
	else:
		return error
