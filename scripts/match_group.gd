class_name MatchGroup
extends PanelContainer


@export var group_number: int = 1:
	set(value):
		group_number = max(1, value)
		group_label.text = "Group %d : " % group_number


@onready var matches_grid: GridContainer = $VBoxContainer/MatchesGrid
@onready var group_label: Label = $VBoxContainer/HBoxContainer/GroupLabel


func _ready() -> void:
	group_label.text = "Group %d : " % group_number
	if not matches_grid.child_entered_tree.is_connected(square_grid):
		matches_grid.child_entered_tree.connect(square_grid)
	square_grid()

## This sets the collumns of the matches grid so that the grid elements will be 
## arranged in a square grid. 
func square_grid(_node: Node = null) -> void:
	matches_grid.columns = max(1, int(ceil(sqrt(matches_grid.get_child_count()))))
