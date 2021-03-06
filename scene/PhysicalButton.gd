extends Area

signal pressed()

func _input_event(camera: Object, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton
		&& event.button_index == 1
		&& event.is_pressed()
	):
		emit_signal("pressed")
		Sound.instance("GUI GreenButton").attach(self).start()
