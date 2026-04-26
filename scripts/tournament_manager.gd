class_name TournamentManager
extends PanelContainer


enum DisplayModes {
	ACTION_SELECT,
	CONTENT,
}


@onready var header_panel_container: PanelContainer = $VboxContainer/HeaderPanelContainer
@onready var back_button: Button = $VboxContainer/HeaderPanelContainer/Header/BackButton
@onready var settings_button: Button = $VboxContainer/HeaderPanelContainer/Header/SettingsButton
@onready var content_container: HBoxContainer = $VboxContainer/ContentContainer
@onready var new_round_button: Button = $VboxContainer/ContentContainer/VBoxContainer/NextActionPanelContainer/NextActionContainer/NewRoundButton
@onready var reload_button: Button = $VboxContainer/ContentContainer/VBoxContainer/NextActionPanelContainer/NextActionContainer/ReloadButton
@onready var action_select_panel_container: PanelContainer = $ActionSelectPanelContainer
@onready var load_tournament_button: Button = $ActionSelectPanelContainer/ActionSelectionContainer/LoadTournamentButton
@onready var new_tournament_button: Button = $ActionSelectPanelContainer/ActionSelectionContainer/NewTournamentButton
@onready var player_list_display: PlayerListDisplay = $VboxContainer/ContentContainer/ScrollContainer/PlayerListDisplay
@onready var tournament_settings_ui_edit: TournamentSettingsUIEdit = $VboxContainer/ContentContainer/VBoxContainer/TournamentSettingsUIEdit


func _ready() -> void:
	tournament_settings_ui_edit.ko_advancement_container.hide()



func switch_display_mode(mode: DisplayModes) -> void:
	match mode:
		DisplayModes.ACTION_SELECT:
			action_select_panel_container.show()
			content_container.hide()
		DisplayModes.CONTENT:
			action_select_panel_container.hide()
			content_container.show()
