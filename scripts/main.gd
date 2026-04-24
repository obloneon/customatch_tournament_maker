class_name Main
extends Node


const RESULT_DISPLAY = preload("uid://cv2rl6tfwork4")
const SETTINGS_UI = preload("uid://cl0ywm7nwp0db")
const START_SCREEN = preload("uid://bgvrtmmcmg17s")
const SWISS_ROUND_UI = preload("uid://c57l0xsnvoaut")
const TOURNAMENT_MANAGER = preload("uid://871px2vvgsth")

# Data
## The swiss round currently in progress
var current_swiss_round: SwissRound
## All created swisss rounds of the current session indexed by their round number
var swiss_rounds: Dictionary[int, SwissRound] = {}
var player_list: Array[Player]
# UI Scenes
var result_display: ResultDisplay
var settings_ui: SettingsUI
var start_screen: StartScreen
var swiss_round_ui: SwissRoundUI
var tournament_manager: TournamentManager 

@onready var content_layer: CanvasLayer = $ContentLayer
@onready var player_import: PlayerImport = $PlayerImport
@onready var settings_layer: CanvasLayer = $SettingsLayer


func _ready() -> void:
	_main()


func _main() -> void:
	player_import.hide()
	# Add ui scenes to scene tree
	result_display = _add_scene_to(RESULT_DISPLAY, content_layer)
	start_screen = _add_scene_to(START_SCREEN, content_layer)
	swiss_round_ui = _add_scene_to(SWISS_ROUND_UI, content_layer)
	tournament_manager = _add_scene_to(TOURNAMENT_MANAGER, content_layer)
	# Connect signals
	# StartScreen signals
	start_screen.start_button.pressed.connect(
		_switch_scene.bind(start_screen, tournament_manager)
	)
	start_screen.start_button.pressed.connect(
		tournament_manager.switch_display_mode.bind(
			tournament_manager.DisplayModes.ACTION_SELECT
		)
	)
	start_screen.quit_button.pressed.connect(_quit)
	# TournamentManager signals
	tournament_manager.back_button.button_up.connect(
		_switch_scene.bind(tournament_manager, start_screen)
	)
	tournament_manager.load_tournament_button.button_up.connect(_load_tournament)
	tournament_manager.new_tournament_button.button_up.connect(_confirm_new_tournament)
	tournament_manager.new_round_button.button_down.connect(
		_update_tournament_settings.bind(
			tournament_manager.tournament_settings_ui_edit
		)
	)
	tournament_manager.new_round_button.button_down.connect(_generate_swiss_round)
	tournament_manager.new_round_button.button_down.connect(
		_switch_scene.bind(tournament_manager, swiss_round_ui)
	)
	tournament_manager.reload_button.button_down.connect(player_import.show)
	tournament_manager.settings_button.button_down.connect(_open_settings)
	# PlayerImport signals
	if not player_import.players_imported.is_connected(_update_player_list):
		player_import.players_imported.connect(_update_player_list)
	player_import.close_button.pressed.connect(
		tournament_manager.switch_display_mode.bind(
			tournament_manager.DisplayModes.ACTION_SELECT
		)
	)
	# SwissRoundUI signals
	swiss_round_ui.new_round_button.button_up.connect(_generate_swiss_round)
	swiss_round_ui.back_button.button_up.connect(_confirm_round_deletion)
	swiss_round_ui.results_button.button_up.connect(_load_result)
	swiss_round_ui.results_button.button_up.connect(
		_switch_scene.bind(swiss_round_ui, result_display)
	)
	swiss_round_ui.settings_button.button_up.connect(_open_settings)
	# ResultDisplay signals
	result_display.back_button.button_up.connect(
		_switch_scene.bind(result_display, swiss_round_ui)
	)
	result_display.settings_button.button_up.connect(_open_settings)
	result_display.title_screen_button.button_up.connect(_restart)
	# Start
	start_screen.show()


func _add_scene_to(scene_res: PackedScene, target: Node) -> Node:
	var scene_instance = scene_res.instantiate() as Node
	target.add_child(scene_instance)
	scene_instance.hide()
	return scene_instance


func _confirm_new_tournament() -> void:
	# No confirmation needed if no prior data can be lost
	if swiss_rounds.is_empty():
		player_import.show()
		tournament_manager.switch_display_mode(tournament_manager.DisplayModes.CONTENT)
	else:
	# If prior data exists warn user
		var confirmation_dialog := ConfirmationDialog.new()
		confirmation_dialog.dialog_text = (
			"Creating a new tournament will delete the currently existing one!
			Any entered results and all finished rounds will be lost!"
		)
		confirmation_dialog.initial_position = (
			Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		) 
		confirmation_dialog.min_size = Vector2(1000.0, 124.0)
		confirmation_dialog.canceled.connect(confirmation_dialog.queue_free)
		confirmation_dialog.confirmed.connect(
			tournament_manager.switch_display_mode.bind(
				tournament_manager.DisplayModes.CONTENT
			)
		)
		confirmation_dialog.confirmed.connect(func(): swiss_rounds.clear())
		confirmation_dialog.confirmed.connect(player_import.show)
		confirmation_dialog.show()
		add_child(confirmation_dialog)


func _confirm_round_deletion() -> void:
	var confirmation_dialog := ConfirmationDialog.new()
	confirmation_dialog.dialog_text = (
		"Going back will delete this round!\nAny entered results will be lost!"
	)
	confirmation_dialog.initial_position = (
		Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	)
	confirmation_dialog.min_size = Vector2(600.0, 124.0)
	confirmation_dialog.canceled.connect(confirmation_dialog.queue_free)
	confirmation_dialog.confirmed.connect(_load_previous_round)
	confirmation_dialog.show()
	add_child(confirmation_dialog)


func _generate_swiss_round() -> void:
	if current_swiss_round != null:
		player_list = current_swiss_round.get_players()
		print("current round:")
		_print_swiss_round(current_swiss_round)
	if player_list.is_empty():
		return
	current_swiss_round = SwissRound.new()
	current_swiss_round.swiss_round_number = swiss_rounds.size() + 1
	current_swiss_round.matches = current_swiss_round.assign_players_to_matches(player_list)
	swiss_rounds[current_swiss_round.swiss_round_number] = current_swiss_round
	swiss_round_ui.swiss_round_res = current_swiss_round
	swiss_round_ui.update()


func _load_result() -> void:
	if swiss_rounds.is_empty():
		push_error("no swiss rounds have been played")
		return
	var last_round := swiss_rounds[swiss_rounds.size()]
	_print_swiss_round(last_round)
	result_display.player_list_display.player_list = last_round.get_players()
	result_display.player_list_display.update()


func _load_previous_round() -> void:
	if current_swiss_round == null:
		push_error("no swiss round res loaded")
		return
	if swiss_rounds.size() < 2 or current_swiss_round.swiss_round_number == 1:
		swiss_rounds.erase(1)
		_switch_scene(swiss_round_ui, tournament_manager)
	else:
		var previous_round_number: int = current_swiss_round.swiss_round_number - 1
		if not swiss_rounds.has(previous_round_number):
			push_error("no previous round in swiss rounds")
			return
		swiss_rounds.erase(current_swiss_round.swiss_round_number)
		var previous_round = swiss_rounds[previous_round_number]
		swiss_round_ui.swiss_round_res = previous_round
		current_swiss_round = previous_round
		swiss_round_ui.update()


func _load_tournament() -> void:
	pass # not yet implemented


func _open_settings() -> void:
	pass # not yet implemented
	#if settings_layer.get_children().is_empty():
		#settings_ui = _add_scene_to(SETTINGS_UI, settings_layer)


func _print_swiss_round(swiss_round: SwissRound) -> void:
	var round_seperator := "========================================"
	var match_seperator := "----------------------------------------"
	print(round_seperator)
	print("Swiss Round Nr. " + str(swiss_round.swiss_round_number))
	for match_res in swiss_round.matches:
		print(match_seperator)
		if match_res.station.is_special_station:
			print("Match at special station %d:" % match_res.station.number)
		else:
			print("Match at station %d:" % match_res.station.number)
		var player_result_header: String = "	Name |      Placement | Wins | Points | Played at Special"
		print(player_result_header)
		for player: Player in match_res.result.keys():
			var player_result_template: String = "	%s |         %s |    %s |      %s | %s"
			var string_var_array := []
			string_var_array.append(player.name)
			string_var_array.append(str(match_res.result[player]))
			string_var_array.append(str(player.wins))
			string_var_array.append(str(player.points))
			string_var_array.append(str(player.played_at_special_station))
			print(player_result_template % string_var_array)


func _quit() -> void:
	get_tree().quit()


func _restart()-> void:
	for layer in get_children():
		while layer.get_children().size() > 0:
			var child = layer.get_child(0)
			layer.remove_child(child)
			child.queue_free()
	_main()


func _switch_scene(from: Node, to: Node) -> void:
	from.hide()
	to.show()


func _update_player_list(players: Array[Player]) -> void:
	player_list = players # When from player import then its affected by changes to imported players
	if tournament_manager.new_round_button.disabled:
		tournament_manager.new_round_button.disabled = false
	if player_list.size() < 2:
		tournament_manager.new_round_button.disabled = true
	tournament_manager.player_list_display.player_list = player_list
	tournament_manager.player_list_display.update()


func _update_tournament_settings(setting_edit: TournamentSettingsUIEdit) -> void:
	var settings_changed := false
	if setting_edit.match_size_edit.text != "":
		Global.tournament_settings.match_size  = (
			int(setting_edit.match_size_edit.text)
		)
		setting_edit.match_size_edit.placeholder_text = (
			setting_edit.match_size_edit.text
		)
		settings_changed = true
	if setting_edit.station_count_edit.text != "":
		Global.tournament_settings.station_count = (
			int(setting_edit.station_count_edit.text)
		)
		setting_edit.station_count_edit.placeholder_text = (
			setting_edit.station_count_edit.text
		)
		settings_changed = true
	if setting_edit.special_stations_edit.text != "":
		Global.tournament_settings.special_stations = (
			int(setting_edit.special_stations_edit.text)
		)
		setting_edit.special_stations_edit.placeholder_text = (
			setting_edit.special_stations_edit.text
		)
		settings_changed = true
	if setting_edit.special_station_name_edit.text != "":
		Global.tournament_settings.special_station_name = (
			setting_edit.special_station_name_edit.text
		)
		setting_edit.special_stations_name_edit.placeholder_text = (
			setting_edit.special_stations_name_edit.text
		)
		settings_changed = true
	if settings_changed:
		Global.tournament_settings.save()
