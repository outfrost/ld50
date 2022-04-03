extends Spatial

export(float, 0.0, 10.0) var conveyor_speed: float = 1.02
export var assembly_scene: PackedScene
export var attachment_preview_path: NodePath

onready var spawn_point: Spatial = $AssemblySpawnPoint
onready var assembly_point: Spatial = $AssemblyAssemblyPoint
onready var exit_point: Spatial = $AssemblyExitPoint
onready var tween: Tween = $Tween
onready var belt = $conveyorBeltChunkv01
onready var attachment_preview: Spatial = get_node(attachment_preview_path)

var current_assembly: Spatial
var last_assembly: Spatial
var sendable: bool = false

var picked_attachment_scene: PackedScene = null
var picked_attachment: Spatial
var target_attachment_rotation: Basis

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = randi()
	tween.connect("tween_completed", self, "tween_completed")
	for bucket in $PartsBuckets.get_children():
		bucket.connect("part_picked", self, "part_picked")

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton
		&& event.button_index == 2
		&& event.is_pressed()
	):
		unpick_part()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("rotate_attachment_yaw_cw"):
		target_attachment_rotation = target_attachment_rotation.rotated(Vector3.UP, - 0.25 * TAU)
		tween_attachment_rotation()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("rotate_attachment_yaw_ccw"):
		target_attachment_rotation = target_attachment_rotation.rotated(Vector3.UP, 0.25 * TAU)
		tween_attachment_rotation()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("rotate_attachment_pitch_cw"):
		target_attachment_rotation = target_attachment_rotation.rotated(Vector3.RIGHT, - 0.25 * TAU)
		tween_attachment_rotation()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("rotate_attachment_pitch_ccw"):
		target_attachment_rotation = target_attachment_rotation.rotated(Vector3.RIGHT, 0.25 * TAU)
		tween_attachment_rotation()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("rotate_attachment_roll_cw"):
		target_attachment_rotation = target_attachment_rotation.rotated(Vector3.FORWARD, 0.25 * TAU)
		tween_attachment_rotation()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("rotate_attachment_roll_ccw"):
		target_attachment_rotation = target_attachment_rotation.rotated(Vector3.FORWARD, - 0.25 * TAU)
		tween_attachment_rotation()
		get_tree().set_input_as_handled()

func tween_attachment_rotation() -> void:
	if picked_attachment:
		tween.interpolate_property(
			picked_attachment,
			"transform:basis",
			picked_attachment.transform.basis,
			target_attachment_rotation,
			0.125,
			Tween.TRANS_LINEAR)
		tween.start()

func spawn_assembly() -> void:
	current_assembly = assembly_scene.instance()
	tween.interpolate_property(
		current_assembly,
		"transform",
		spawn_point.transform,
		assembly_point.transform,
		(assembly_point.transform.origin - spawn_point.transform.origin).length() / conveyor_speed,
		Tween.TRANS_LINEAR)
	tween.start()
	belt.roll(conveyor_speed / 1.02)
	add_child(current_assembly)
	current_assembly.generate(9)
	current_assembly.connect("clicked", self, "assembly_clicked")

func send_assembly() -> void:
	if !sendable:
		return
	sendable = false

	# hide new attachment placement visualisation and prevent placing stuff
	current_assembly.hoverable = false
	current_assembly.hover_vis.hide()

	# clean up leftover nonsense
	if last_assembly:
		remove_child(last_assembly)
		last_assembly.queue_free()
		last_assembly = null

	last_assembly = current_assembly
	spawn_assembly()

	# roll the finished one out the door
	tween.interpolate_property(
		last_assembly,
		"transform",
		assembly_point.transform,
		exit_point.transform,
		(exit_point.transform.origin - assembly_point.transform.origin).length() / conveyor_speed,
		Tween.TRANS_LINEAR)
	tween.start()
	belt.roll(conveyor_speed / 1.02)

func tween_completed(object: Object, _key: NodePath) -> void:
	if object == last_assembly:
		belt.stop()
		# TODO grade finished assembly?
		remove_child(last_assembly)
		last_assembly.queue_free()
		last_assembly = null
	if object == current_assembly:
		belt.stop()
		sendable = true
		current_assembly.hoverable = true

func part_picked(part_scene: PackedScene) -> void:
	unpick_part()
	if !part_scene:
		return
	picked_attachment_scene = part_scene
	picked_attachment = picked_attachment_scene.instance()

	# randomise attachment rotation
	picked_attachment.rotation = Vector3(
		rng.randi_range(0, 3) * 0.25 * TAU,
		rng.randi_range(0, 3) * 0.25 * TAU,
		rng.randi_range(0, 3) * 0.25 * TAU
	)

	target_attachment_rotation = picked_attachment.transform.basis
	attachment_preview.add_child(picked_attachment)

func unpick_part() -> void:
	picked_attachment_scene = null
	picked_attachment = null
	for child in attachment_preview.get_children():
		attachment_preview.remove_child(child)
		child.queue_free()

func assembly_clicked() -> void:
	if !picked_attachment_scene:
		return

	var euler = target_attachment_rotation.get_euler()
	var degrees = Vector3(rad2deg(euler.x), rad2deg(euler.y), rad2deg(euler.z))
	if current_assembly.try_place_attachment(picked_attachment_scene, degrees):
		unpick_part()
