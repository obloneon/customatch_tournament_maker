class_name ResultDisplay
extends PanelContainer


@onready var back_button: Button = $VboxContainer/HeaderPanelContainer/Header/BackButton
@onready var settings_button: Button = $VboxContainer/HeaderPanelContainer/Header/SettingsButton
@onready var player_list_display: PlayerListDisplay = $VboxContainer/ContentContainer/ScrollContainer/PlayerListDisplay
@onready var new_top_cut_button: Button = $VboxContainer/ContentContainer/VBoxContainer/NextActionPanelContainer/NextActionContainer/NewTopCutButton
@onready var title_screen_button: Button = $VboxContainer/ContentContainer/VBoxContainer/NextActionPanelContainer/NextActionContainer/TitleScreenButton
