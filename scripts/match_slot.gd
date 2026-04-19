class_name MatchSlot
extends PanelContainer
## UI element to display a players name and to enter their placement in a match.
##
## [b]Warning![/b][br]
## This class is not meant to be instantiated manually. The [MatchContainer] class
## automatically intantiates the needed match slots for itself.[br]


## The [Player] whose name is displayed by this match slot.
@export var player_res: Player

@onready var player_label: Label = $HBoxContainer/PanelContainerPlayer/PlayerLabel
@onready var placement_input: LineEdit = $HBoxContainer/PanelContainePlacement/PlacementInput


func _ready() -> void:
	player_label.visible_characters = Global.ui_setings.player_name_max_characters
