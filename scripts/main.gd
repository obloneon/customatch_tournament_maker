class_name Main
extends Node


const RESULT_DISPLAY = preload("uid://cv2rl6tfwork4")
const SETTINGS_UI = preload("uid://cl0ywm7nwp0db")
const START_SCREEN = preload("uid://bgvrtmmcmg17s")
const TOURNAMENT_ROUND_UI = preload("uid://c57l0xsnvoaut")
const TOURNAMENT_MANAGER = preload("uid://871px2vvgsth")

# Data
## The round currently in progress
var current_round: TournamentRound:
	set(value):
		if tournament_round_ui.new_round_button.button_up.is_connected(_generate_ko_round):
			tournament_round_ui.new_round_button.button_up.disconnect(_generate_ko_round)
		if tournament_round_ui.new_round_button.button_up.is_connected(_generate_swiss_round):
			tournament_round_ui.new_round_button.button_up.disconnect(_generate_swiss_round)
		if value != null:
			match value.round_type:
				TournamentRound.RoundType.KO:
					tournament_round_ui.new_round_button.button_up.connect(_generate_ko_round) 
				TournamentRound.RoundType.SWISS:
					tournament_round_ui.new_round_button.button_up.connect(_generate_swiss_round)
				_:
					push_warning("setting a round with no valid round type")
		else:
			print("current round set to null")
		current_round = value
var player_list: Array[Player]
# UI Scenes
var result_display: ResultDisplay
var settings_ui: SettingsUI
var start_screen: StartScreen
var tournament_round_ui: TournamentRoundUI
var tournament_manager: TournamentManager 

@onready var content_layer: CanvasLayer = $ContentLayer
@onready var player_import: PlayerImport = $PlayerImport
@onready var settings_layer: CanvasLayer = $SettingsLayer


func _ready() -> void:
	if Global.tournament == null:
		push_error("No tournament loaded")
		return
	_main()


func _main() -> void:
	player_import.hide()
	# Add ui scenes to scene tree
	result_display = _add_scene_to(RESULT_DISPLAY, content_layer)
	start_screen = _add_scene_to(START_SCREEN, content_layer)
	tournament_round_ui = _add_scene_to(TOURNAMENT_ROUND_UI, content_layer)
	tournament_manager = _add_scene_to(TOURNAMENT_MANAGER, content_layer)
	# Scene setup
	if not Global.tournament.rounds.is_empty():
		tournament_manager.load_tournament_button.show()
	# Connect signals
	# StartScreen signals
	start_screen.start_button.pressed.connect(
		_switch_scene_to.bind(tournament_manager, start_screen)
	)
	start_screen.start_button.pressed.connect(
		tournament_manager.switch_display_mode.bind(
			tournament_manager.DisplayModes.ACTION_SELECT
		)
	)
	start_screen.quit_button.pressed.connect(_quit)
	# TournamentManager signals
	tournament_manager.back_button.button_up.connect(
		_switch_scene_to.bind(start_screen, tournament_manager)
	)
	tournament_manager.load_tournament_button.button_up.connect(
		_load_round.bind(Global.tournament.rounds.size())# loads the last round
	)
	tournament_manager.new_tournament_button.button_up.connect(_confirm_new_tournament)
	tournament_manager.new_round_button.button_up.connect(
		tournament_manager.tournament_settings_ui_edit.save_changes
	)
	tournament_manager.new_round_button.button_up.connect(_generate_swiss_round) # later should be _open_round_type_selection 
	tournament_manager.reload_button.button_up.connect(player_import.show)
	tournament_manager.settings_button.button_up.connect(_open_settings)
	# PlayerImport signals
	if not player_import.players_imported.is_connected(_update_player_list):
		player_import.players_imported.connect(_update_player_list)
	player_import.close_button.pressed.connect(
		tournament_manager.switch_display_mode.bind(
			tournament_manager.DisplayModes.ACTION_SELECT
		)
	)
	# RoundUI signals
	tournament_round_ui.new_round_button.button_up.connect(_generate_swiss_round) # later should be _open_round_type_selection 
	tournament_round_ui.back_button.button_up.connect(_confirm_round_deletion)
	tournament_round_ui.results_button.button_up.connect(_load_result)
	tournament_round_ui.results_button.button_up.connect(
		_switch_scene_to.bind(result_display, tournament_round_ui)
	)
	tournament_round_ui.settings_button.button_up.connect(_open_settings)
	# ResultDisplay signals
	result_display.back_button.button_up.connect(
		_switch_scene_to.bind(tournament_round_ui, result_display)
	)
	result_display.new_top_cut_button.button_up.connect(
		result_display.tournament_settings_ui_edit.save_changes
	)
	result_display.new_top_cut_button.button_up.connect(_confirm_top_cut)
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
	if Global.tournament.rounds.is_empty():
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
		confirmation_dialog.confirmed.connect(
			func(): Global.tournament = Tournament.create_new()
		)
		confirmation_dialog.confirmed.connect(
			tournament_manager.tournament_settings_ui_edit._update_placeholder_text
		)
		confirmation_dialog.confirmed.connect(func(): player_list.clear())
		confirmation_dialog.confirmed.connect(func(): current_round = null)
		confirmation_dialog.confirmed.connect(player_import.show)
		confirmation_dialog.confirmed.connect(confirmation_dialog.queue_free)
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
	confirmation_dialog.confirmed.connect(confirmation_dialog.queue_free)
	confirmation_dialog.show()
	add_child(confirmation_dialog)


func _confirm_top_cut() -> void:
	if player_list.is_empty():
		if current_round != null:
			player_list = current_round.get_players()
		else:
			push_error("Player list is empty cant create top cut")
	var cut_count: int = 16
	while player_list.size() < cut_count:
		cut_count /= 2
	var confirmation_dialog := ConfirmationDialog.new()
	confirmation_dialog.dialog_text = (
		"Create top cut with %d" % cut_count
	)
	confirmation_dialog.initial_position = (
		Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	)
	confirmation_dialog.min_size = Vector2(600.0, 124.0)
	confirmation_dialog.canceled.connect(confirmation_dialog.queue_free)
	confirmation_dialog.confirmed.connect(_create_top_cut.bind(cut_count))
	confirmation_dialog.confirmed.connect(confirmation_dialog.queue_free)
	confirmation_dialog.show()
	add_child(confirmation_dialog)


func _create_top_cut(cut_count: int) -> void:
	var cut_list = player_list.duplicate()
	cut_list.sort_custom(HelperFunctions.compare_players)
	var error = cut_list.resize(cut_count)
	if error != OK:
		push_error("Failed to create top cut - Error: %s" % error_string(error))
		return
	if cut_list.is_empty():
		push_error("Failed to create top cut - Error: cut list is empty")
		return
	current_round = KORound.new()
	current_round.setup_new_round(cut_list)
	error = current_round.save_to_tournament()
	if error != OK:
		push_error("Could not generate round - Error: %s" % error_string(error))
		return
	tournament_round_ui.round_res = current_round
	tournament_round_ui.update()
	if not tournament_round_ui.visible:
		_switch_scene_to(tournament_round_ui)


func _generate_ko_round() -> void:
	print("generate KO")
	if current_round != null:
		player_list = current_round.get_players()
	if player_list.is_empty():
		push_error("Could not generate round - Error: player_list is empty")
		return
	var advancing_players = player_list.duplicate().filter(
		func(player: Player):
			var previous_round_number: int = current_round.round_number
			if not Global.tournament.rounds.has(previous_round_number):
				return true # does not filter if there is no previous round 
			#var previous_round := Global.tournament.rounds[previous_round_number] # need to find a solution for trasition outside of top cut
			#if previous_round.round_type == TournamentRound.RoundType.KO:
			var advancement_limit: int = Global.tournament.settings.ko_advancement_limit
			if not player.placement_in_round.has(previous_round_number):
				return false # Filters out players that did not play before
			return player.placement_in_round[previous_round_number] <= advancement_limit
			#else:
				#return true # does not filter if previous round is not a KO round
	)
	if advancing_players.is_empty():
		push_error("Could not generate KO round - Error: advancing_players is empty")
		return
	current_round = KORound.new()
	current_round.setup_new_round(advancing_players)
	var error := current_round.save_to_tournament()
	if error != OK:
		push_error("Could not generate round - Error: %s" % error_string(error))
		return
	tournament_round_ui.round_res = current_round
	tournament_round_ui.update()
	if not tournament_round_ui.visible:
		_switch_scene_to(tournament_round_ui)


func _generate_swiss_round() -> void:
	if current_round != null:
		_print_swiss_round(current_round)
		player_list = current_round.get_players()
	if player_list.is_empty():
		push_error("Could not generate round - Error: player_list is empty")
		return
	current_round = SwissRound.new()
	current_round.setup_new_round(player_list)
	var error := current_round.save_to_tournament()
	if error != OK:
		push_error("Could not generate round - Error: %s" % error_string(error))
		return
	tournament_round_ui.round_res = current_round
	tournament_round_ui.update()
	if not tournament_round_ui.visible:
		_switch_scene_to(tournament_round_ui)


func _load_result() -> void:
	if Global.tournament.rounds.is_empty():
		push_error("no swiss rounds have been played")
		return
	var last_round := Global.tournament.rounds[Global.tournament.rounds.size()]
	if last_round.round_type == TournamentRound.RoundType.SWISS:
		_print_swiss_round(last_round)
	result_display.player_list_display.player_list = last_round.get_players()
	result_display.player_list_display.update()


func _load_previous_round() -> void:
	if current_round == null:
		push_error("no round loaded")
		return
	if Global.tournament.rounds.size() < 2 or current_round.round_number == 1:
		Global.tournament.rounds.erase(1)
		_switch_scene_to(tournament_manager, tournament_round_ui)
	else:
		var previous_round_number: int = current_round.round_number - 1
		if not Global.tournament.rounds.has(previous_round_number):
			push_error("no previous round in tournament rounds")
			return
		Global.tournament.rounds.erase(current_round.round_number)
		_load_round(previous_round_number)


func _load_round(round_number: int) -> void:
	if not Global.tournament.rounds.has(round_number):
		push_error("Round %d does not exist in tournament rounds" % round_number)
		return
	var selected_round = Global.tournament.rounds[round_number]
	tournament_round_ui.round_res = selected_round
	tournament_round_ui.update()
	_switch_scene_to(tournament_round_ui)
	current_round = selected_round
	player_list = current_round.get_players() # just to be safe 


func _open_round_type_selection() -> void:
	pass # not yet implemented


func _open_settings() -> void:
	pass # not yet implemented
	#if settings_layer.get_children().is_empty():
		#settings_ui = _add_scene_to(SETTINGS_UI, settings_layer)


func _open_top_cut_dialog() -> void:
	pass # not yet implemented


## Can be used to check if the ui displays the correct matches/ results
func _print_swiss_round(swiss_round: SwissRound) -> void:
	var round_seperator := "========================================"
	var match_seperator := "----------------------------------------"
	print(round_seperator)
	print(" Round Nr. " + str(swiss_round.round_number))
	for match_res in swiss_round.matches:
		print(match_seperator)
		if match_res.station.is_special_station:
			print("Match at special station %d:" % match_res.station.number)
		else:
			print("Match at station %d:" % match_res.station.number)
		var player_result_header: String = "	Name |   Placement | Wins | Points | Played at Special"
		print(player_result_header)
		for player: Player in match_res.result.keys():
			var player_result_template: String = "	%s   |          %s |   %s |     %s | %s"
			var string_var_array := [
				player.name,
				str(match_res.result[player]),
				str(player.wins),
				str(player.points),
				str(player.played_at_special_station)
			]
			print(player_result_template % string_var_array)


func _quit() -> void:
	var error = Global.tournament.save()
	if error != OK:
		push_error("Could not save - Error: " + error_string(error))
		return
	get_tree().quit()


func _restart()-> void:
	for layer in get_children():
		if layer is PlayerImport:
			continue # Player import does not need to be reloaded
		while layer.get_children().size() > 0:
			var child = layer.get_child(0)
			layer.remove_child(child)
			child.queue_free()
	_main()


## Pass in the old scene if its known for better performance.
func _switch_scene_to(new_scene: Node, old_scene: Node = null ) -> void:
	if old_scene == null:
		for child in content_layer.get_children():
			child.hide()
	else:
		old_scene.hide()
	new_scene.show()


func _update_player_list(players: Array[Player]) -> void:
	player_list = players # When from player import then its affected by changes to imported players
	if tournament_manager.new_round_button.disabled:
		tournament_manager.new_round_button.disabled = false
	if player_list.size() < 2:
		tournament_manager.new_round_button.disabled = true
	tournament_manager.player_list_display.player_list = player_list
	tournament_manager.player_list_display.update()
