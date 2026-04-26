class_name PlayerListDisplay
extends PanelContainer


const PLAYER_LIST_LABELS_STYLE_BOX_FLAT = preload("uid://vihb6mhogh73")

@export var player_list: Array[Player]
@export var round_res: TournamentRound
@export var show_placement: bool = true
@export var show_wins: bool = true
@export var show_points: bool = true
@export var show_average_opponent_points: bool = true
 
@onready var grid_container: GridContainer = $GridContainer
@onready var placement_column_label: Label = $GridContainer/PlacementColumnLabel
@onready var win_column_label: Label = $GridContainer/WinColumnLabel
@onready var points_column_label: Label = $GridContainer/PointsColumnLabel


func update() -> void:
	# Remove old grid content except for coulumn labels
	while grid_container.get_child_count() > 5:
		var child = grid_container.get_child(-1)
		grid_container.remove_child(child)
		child.queue_free()
	if player_list == null or player_list.is_empty():
		if round_res:
			player_list = round_res.get_players()
		else:
			push_warning("no players to display")
			return
	grid_container.columns = _calculate_needed_columns()
	placement_column_label.visible = show_placement
	win_column_label.visible = show_wins
	points_column_label.visible = show_points
	
	var list_to_display = player_list.duplicate(true)
	if show_placement:
		list_to_display.sort_custom(HelperFunctions.compare_players)
	for i in list_to_display.size():
		if show_placement:
			var label = Label.new()
			label.text = str(i + 1)+ "."
			label.add_theme_stylebox_override("normal", PLAYER_LIST_LABELS_STYLE_BOX_FLAT)
			grid_container.add_child(label)
		# player name is always added
		var name_label = Label.new()
		name_label.text = list_to_display[i].name
		name_label.add_theme_stylebox_override("normal", PLAYER_LIST_LABELS_STYLE_BOX_FLAT)
		grid_container.add_child(name_label)
		if show_points:
			var label = Label.new()
			label.text = str(list_to_display[i].points)
			label.add_theme_stylebox_override("normal", PLAYER_LIST_LABELS_STYLE_BOX_FLAT)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			grid_container.add_child(label)
		if show_wins:
			var label = Label.new()
			label.text = str(list_to_display[i].wins)
			label.add_theme_stylebox_override("normal", PLAYER_LIST_LABELS_STYLE_BOX_FLAT)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			grid_container.add_child(label)
		if show_average_opponent_points:
			var label = Label.new()
			label.text = str(snapped(HelperFunctions.calculate_average_opponent_points(list_to_display[i]), 0.001))
			label.add_theme_stylebox_override("normal", PLAYER_LIST_LABELS_STYLE_BOX_FLAT)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			grid_container.add_child(label)


func _calculate_needed_columns() -> int:
	var needed_columns_count: int = 1
	if show_placement:
		needed_columns_count += 1
	if show_wins:
		needed_columns_count += 1
	if show_points:
		needed_columns_count += 1
	if show_average_opponent_points:
		needed_columns_count += 1
	return needed_columns_count
