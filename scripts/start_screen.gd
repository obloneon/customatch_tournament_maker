class_name StartScreen
extends PanelContainer


@onready var quit_button: Button = $HBoxContainer/QuitButton
@onready var start_button: Button = $Control/StartButton
@onready var version_label: Label = $Control/VersionLabel


func _ready() -> void:
	version_label.text = (
		"v" + ProjectSettings.get_setting("application/config/version") as String
	)
