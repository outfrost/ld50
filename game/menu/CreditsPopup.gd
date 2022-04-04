extends Popup

func _ready() -> void:
	$Panel/RichTextLabel.connect("meta_clicked", self, "on_meta_clicked")
	$Panel/CloseButton.connect("pressed", self, "on_close_pressed")

func _input(event: InputEvent) -> void:
	if !visible:
		return
	if event.is_action("ui_cancel") && event.is_pressed():
		hide()
		get_tree().set_input_as_handled()

func _gui_input(event):
	if (
		event is InputEventMouseButton
		&& event.button_index == BUTTON_LEFT
		&& !event.is_pressed()
	):
		hide()
		accept_event()

func on_meta_clicked(meta: String):
	if meta.begins_with("http"):
		OS.shell_open(meta)
	Sound.play("GUI Click")

func on_close_pressed() -> void:
	hide()
	Sound.play("GUI Click")
