extends Spatial

export(float, 0.0, 10.0) var conveyor_speed: float = 1.02
export var assembly_scene: PackedScene

onready var spawn_point: Spatial = $AssemblySpawnPoint
onready var assembly_point: Spatial = $AssemblyAssemblyPoint
onready var exit_point: Spatial = $AssemblyExitPoint
onready var tween: Tween = $Tween
onready var belt = $conveyorBeltChunkv01

var current_assembly: Spatial
var last_assembly: Spatial
var sendable: bool = false

func _ready() -> void:
	tween.connect("tween_completed", self, "tween_completed")

func spawn_assembly() -> void:
	current_assembly = assembly_scene.instance()
	current_assembly.generate(5)
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
	last_assembly = current_assembly
	spawn_assembly()
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
