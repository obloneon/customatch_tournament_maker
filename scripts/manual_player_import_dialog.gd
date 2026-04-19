class_name ManualPlayerImportDialog
extends AcceptDialog


signal entered_text_to_import(text: String)

@onready var text_edit: TextEdit = $TextEdit


func _ready() -> void:
	text_edit.placeholder_text = "player1\nplayer2\nplayer3\n..."
	if not self.confirmed.is_connected(_on_confirmed):
		self.confirmed.connect(_on_confirmed)


func _on_confirmed() -> void:
	entered_text_to_import.emit(text_edit.text)
