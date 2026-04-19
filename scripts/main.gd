extends Node


@onready var content_layer: CanvasLayer = $ContentLayer
@onready var player_import: PlayerImport = $PlayerImport
@onready var settings: CanvasLayer = $Settings


func _ready() -> void:
	_main()


func _main() -> void:
	while content_layer.get_child_count() > 0:
		var child = content_layer.get_child(0)
		content_layer.remove_child(child)
		child.queue_free()
	player_import.hide()
	settings.hide()
