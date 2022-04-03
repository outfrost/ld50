extends Position3D

export var static_rotation_degrees: Vector3

func _process(delta: float) -> void:
	global_transform.basis = Basis.IDENTITY \
		.rotated(Vector3.FORWARD, deg2rad(static_rotation_degrees.z)) \
		.rotated(Vector3.RIGHT, deg2rad(static_rotation_degrees.x)) \
		.rotated(Vector3.UP, deg2rad(static_rotation_degrees.y))
