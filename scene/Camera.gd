extends Camera

export(float, 0.0, 60.0) var rotation_extent_degrees: float = 30.0
export(float, 0.0, 2.0) var aim_area_aspect_ratio: float = 1.0

onready var base_x_rotation_degrees: float = rotation_degrees.x

func _process(delta: float) -> void:
	var viewport: Viewport = get_viewport()
	var viewport_middle: Vector2 = viewport.size * 0.5

	var aim = (
		(viewport.get_mouse_position() - viewport_middle)
		/ viewport_middle.y
	)

	var rotation_proportion = Vector2(
		(smoothstep(- aim_area_aspect_ratio, aim_area_aspect_ratio, aim.x) - 0.5) * 2.0 * aim_area_aspect_ratio,
		(smoothstep(- 1.0, 1.0, aim.y) - 0.5) * 2.0
	)

	# YXZ
	rotation_degrees = rotation_extent_degrees * Vector3(
		- rotation_proportion.y,
		- rotation_proportion.x,
		0.0)
	rotation_degrees.x += base_x_rotation_degrees

#	DebugOverlay.display(aim)
#	DebugOverlay.display(rotation_proportion)
#	DebugOverlay.display(base_x_rotation_degrees)
#	DebugOverlay.display(rotation_degrees)


func _on_Conveyor_finished_assembly(num_connectors, num_attachments):
	pass # Replace with function body.
