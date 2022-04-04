extends Spatial

signal clicked()

export(Array, PackedScene) var blank_scenes: Array
export var blanking_plate_scene: PackedScene
export var hover_vis_scene: PackedScene

onready var hover_vis: Spatial = hover_vis_scene.instance()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var hovered_blank: Spatial = null
var hoverable: bool = false

var num_connectors: int = 0
var num_attachments: int = 0

func _ready() -> void:
	rng.seed = randi()
	hover_vis.hide()
	add_child(hover_vis)

func generate(num_connectors: int) -> void:
	if num_connectors > 16:
		num_connectors = 16
	self.num_connectors = num_connectors
	var blanks = []
	for i in range(0, num_connectors):
		blanks.append(blank_scenes[rng.randi_range(0, blank_scenes.size() - 1)].instance())
	while blanks.size() < 16:
		blanks.append(blanking_plate_scene.instance())

	for ix in range(0, 4):
		for iz in range(0, 4):
			var pos = Vector3(- 0.3 + (ix * 0.2), 0.1, - 0.3 + (iz * 0.2))
			var index = rng.randi_range(0, blanks.size() - 1)
			blanks[index].translation = pos
			blanks[index].rotate_y(rng.randi_range(0, 3) * TAU * 0.25)
			add_child(blanks[index])
			blanks[index].connect("hovered", self, "blank_hovered", [ blanks[index] ])
			blanks[index].connect("unhovered", self, "blank_unhovered", [ blanks[index] ])
			blanks[index].connect("clicked", self, "blank_clicked", [ blanks[index] ])
			blanks.remove(index)

func percent_done() -> float:
	if num_connectors == 0:
		return 1.0
	return float(num_attachments) / float(num_connectors)

func blank_hovered(blank: Spatial) -> void:
	if !hoverable:
		return
	hovered_blank = blank
	hover_vis.translation = hovered_blank.translation + Vector3(0.0, 0.1, 0.0)
	hover_vis.show()
	#Sound.play("Hover", self) Here will be a hover SFX

func blank_unhovered(blank: Spatial) -> void:
	if hovered_blank == blank:
		hovered_blank = null
		hover_vis.hide()

func blank_clicked(blank: Spatial) -> void:
	if !hoverable:
		return
	emit_signal("clicked")



func try_place_attachment(attachment_scene: PackedScene, rotation_deg: Vector3) -> bool:
	if !hovered_blank:
		return false
	if attachment_scene != hovered_blank.attachment_scene:
		hover_vis.flash_red()
		return false

#	print(str(hovered_blank.rotation_degrees) + " --- " + str(rotation_deg))

	# determine attachment orientation
	var adjusted_rotation: Vector3 = rotation_deg - hovered_blank.rotation_degrees
	adjusted_rotation = adjusted_rotation.round()
	adjusted_rotation = adjusted_rotation.posmod(360.0)
	var rotation_check: int = 0
	if (adjusted_rotation.is_equal_approx(Vector3(0.0, 0.0, 0.0))):
		rotation_check = 1
	elif (adjusted_rotation.is_equal_approx(Vector3(0.0, 90.0, 0.0))):
		rotation_check = 2
	elif (adjusted_rotation.is_equal_approx(Vector3(0.0, 180.0, 0.0))):
		rotation_check = 4
	elif (adjusted_rotation.is_equal_approx(Vector3(0.0, 270.0, 0.0))):
		rotation_check = 8

	if !(rotation_check & hovered_blank.attaches_at):
		hover_vis.flash_red()
		return false

	var attachment = attachment_scene.instance()
	attachment.rotation_degrees = rotation_deg
	attachment.translation = hovered_blank.translation
	attachment.translation.y += 0.2
	add_child(attachment)
	num_attachments += 1
	hovered_blank.get_node("CollisionShape").disabled = true
	hovered_blank = null
	hover_vis.hide()
	Sound.play("Click", self)

	return true

