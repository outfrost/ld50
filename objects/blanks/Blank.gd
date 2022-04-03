extends Area

signal hovered()
signal unhovered()

export var attachment_scene: PackedScene
export(int, FLAGS, "0°", "90°", "180°", "270°") var attaches_at = 1

func _ready() -> void:
	connect("mouse_entered", self, "mouse_entered")
	connect("mouse_exited", self, "mouse_exited")

func mouse_entered() -> void:
	emit_signal("hovered")

func mouse_exited() -> void:
	emit_signal("unhovered")
