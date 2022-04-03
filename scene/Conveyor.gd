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

func _ready() -> void:
	tween.connect("tween_completed", self, "tween_completed")
	for bucket in $PartsBuckets.get_children():
		bucket.connect("part_picked", self, "part_picked")

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton
		&& event.button_index == 2
		&& event.is_pressed()
	):
		unpick_part()

func spawn_assembly() -> void:
	current_assembly = assembly_scene.instance()
	current_assembly.generate(5)
	current_assembly.connect("clicked", self, "assembly_clicked")
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
	belt.stop()
	if object == last_assembly:
		# TODO grade finished assembly?
		remove_child(last_assembly)
		last_assembly.queue_free()
		last_assembly = null
	if object == current_assembly:
		sendable = true
		current_assembly.hoverable = true

func part_picked(part_scene: PackedScene) -> void:
	unpick_part()
	if !part_scene:
		return
	picked_attachment_scene = part_scene
	attachment_preview.add_child(picked_attachment_scene.instance())

func unpick_part() -> void:
	picked_attachment_scene = null
	for child in attachment_preview.get_children():
		attachment_preview.remove_child(child)
		child.queue_free()

func assembly_clicked() -> void:
	if !picked_attachment_scene:
		return

	if current_assembly.try_place_attachment(picked_attachment_scene):
		unpick_part()
