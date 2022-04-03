extends Area

signal hovered()
signal unhovered()
signal clicked()

export var attachment_scene: PackedScene
export(int, FLAGS, "0°", "90°", "180°", "270°") var attaches_at = 1

func _ready() -> void:
	connect("mouse_entered", self, "mouse_entered")
	connect("mouse_exited", self, "mouse_exited")

func _input_event(camera: Object, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton
		&& event.button_index == 1
		&& event.is_pressed()
	):
		emit_signal("clicked")

func mouse_entered() -> void:
	emit_signal("hovered")

func mouse_exited() -> void:
	emit_signal("unhovered")
