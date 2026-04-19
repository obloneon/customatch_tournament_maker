class_name PlayerImport
extends CanvasLayer


signal players_imported(imported_players: Array[Player])

const  _MANUAL_IMPORT_DIALOG_UID := "uid://c15ry1mnx8lah"

var imported_players: Array[Player] = []

@onready var close_button: Button = $PanelContainer/VBoxContainer/HeaderPanelContainer/HeaderHBox/CloseButton
@onready var action_selection_container: PanelContainer = $PanelContainer/VBoxContainer/ActionSelectionContainer
@onready var from_file_button: Button = $PanelContainer/VBoxContainer/ActionSelectionContainer/VBoxContainer/FromFileButton
@onready var manual_button: Button = $PanelContainer/VBoxContainer/ActionSelectionContainer/VBoxContainer/ManualButton
@onready var add_player_button: Button = $PanelContainer/VBoxContainer/ActionSelectionContainer/VBoxContainer/AddPlayerButton
@onready var remove_player_button: Button = $PanelContainer/VBoxContainer/ActionSelectionContainer/VBoxContainer/RemovePlayerButton


func _init(existing_players: Array[Player] = []) -> void:
	if not existing_players == []:
		imported_players.append_array(existing_players)


func _ready() -> void:
	# Connect "button_up" signals if not already connected
	if not from_file_button.button_up.is_connected(_open_file_import_window):
		from_file_button.button_up.connect(_open_file_import_window)
	if not manual_button.button_up.is_connected(_open_manual_import_dialog):
		manual_button.button_up.connect(_open_manual_import_dialog)
	if not add_player_button.button_up.is_connected(_open_player_add_dialog):
		add_player_button.button_up.connect(_open_player_add_dialog)
	if not remove_player_button.button_up.is_connected(_open_player_remove_dialog):
		remove_player_button.button_up.connect(_open_player_remove_dialog)
	if not close_button.button_up.is_connected(hide):
		close_button.button_up.connect(hide)


func _open_file_import_window() -> void:
	var import_dialog := FileDialog.new()
	import_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	import_dialog.access = FileDialog.ACCESS_FILESYSTEM
	import_dialog.filters = PackedStringArray(["*.csv", "*.txt"])
	import_dialog.use_native_dialog = true
	import_dialog.visible = true
	add_child(import_dialog)
	import_dialog.file_selected.connect(_import_players_from_file)


func _open_manual_import_dialog() -> void:
	var manual_import_dialog = load(_MANUAL_IMPORT_DIALOG_UID)
	var manual_import_dialog_instance := (
		manual_import_dialog.instantiate() as ManualPlayerImportDialog
	)
	manual_import_dialog_instance.entered_text_to_import.connect(_import_players_from_string)
	add_child(manual_import_dialog_instance)


func _open_player_add_dialog() -> void:
	pass # Replace with function body.


func _open_player_remove_dialog() -> void:
	pass # Replace with function body.


## Transforms a string of player names into an array of players and appends it 
## to imported players.
## The string must be in the following format:
## [codeblock]
## "player1\nplayer2\nplayerN"
## [/codeblock]
func _import_players_from_string(players_string: String, clear_before_import := true) -> void:
	if clear_before_import:
		imported_players.clear()
	var player_names := players_string.split("\n")
	var imported_player_names: Dictionary[String, int] = {}
	for player_name in player_names:
		var striped_name = player_name.strip_edges()
		if striped_name == "":
			continue
		if imported_player_names.has(striped_name):
			striped_name = striped_name + str(imported_player_names[striped_name] + 1)
			imported_player_names[striped_name] += 1
		else:
			imported_player_names[striped_name] = 1
		var new_player = Player.new(striped_name)
		imported_players.append(new_player)
	players_imported.emit(imported_players)
	print(imported_player_names)
	print()
	print()


## Transforms a [code].csv[/code] or [code].txt[/code] file into a string that
## is used by [method PlayerImport._import_players_from_string] to import players 
## from that string.
## The text in a [code].txt[/code] file must be in the following format:
## [codeblock]
## player1
## player2
## ...
## playerN
## [/codeblock]
func _import_players_from_file(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		push_error("Invalid file path: File does not exist")
		return
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file_path.ends_with(".txt"):
		var file_text: String = file.get_as_text()
		_import_players_from_string(file_text)
	elif file_path.ends_with(".csv"):
		var players := []
		while file.get_position() < file.get_length():
			var csv_line := file.get_csv_line()
			# skip empty/malformed lines
			if csv_line.is_empty():
				continue
			for field in csv_line:
				players.append(field.strip_edges())
		var players_string := "\n".join(players)
		_import_players_from_string(players_string)
	else:
		push_error("Invalid file path: File is not a .txt or .csv file")
