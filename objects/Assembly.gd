extends Spatial

signal clicked()

export(Array, PackedScene) var blank_scenes: Array
export var blanking_plate_scene: PackedScene
export var hover_vis_scene: PackedScene

onready var hover_vis: Spatial = hover_vis_scene.instance()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var hovered_blank: Spatial = null
var hoverable: bool = false

func _ready() -> void:
	rng.randomize()
	hover_vis.hide()
	add_child(hover_vis)

func generate(num_connectors: int) -> void:
	if num_connectors > 16:
		num_connectors = 16
	var blanks = []
	for i in range(0, num_connectors):
		blanks.append(blank_scenes[rng.randi_range(0, blank_scenes.size() - 1)].instance())
	while blanks.size() < 16:
		blanks.append(blanking_plate_scene.instance())

	for ix in range(0, 4):
		for iz in range(0, 4):
			var pos = Vector3(- 0.3 + (ix * 0.2), 0.2, - 0.3 + (iz * 0.2))
			var index = rng.randi_range(0, blanks.size() - 1)
			blanks[index].translation = pos
			blanks[index].rotate_y(rng.randi_range(0, 3) * TAU * 0.25)
			add_child(blanks[index])
			blanks[index].connect("hovered", self, "blank_hovered", [ blanks[index] ])
			blanks[index].connect("unhovered", self, "blank_unhovered", [ blanks[index] ])
			blanks[index].connect("clicked", self, "blank_clicked", [ blanks[index] ])
			blanks.remove(index)

func blank_hovered(blank: Spatial) -> void:
	if !hoverable:
		return
	hovered_blank = blank
	hover_vis.translation = hovered_blank.translation + Vector3(0.0, 0.2, 0.0)
	hover_vis.show()

func blank_unhovered(blank: Spatial) -> void:
	if hovered_blank == blank:
		hovered_blank = null
		hover_vis.hide()

func blank_clicked(blank: Spatial) -> void:
	if !hoverable:
		return
	emit_signal("clicked")

func try_place_attachment(attachment_scene: PackedScene) -> bool:
	if !hovered_blank:
		return false
	if attachment_scene != hovered_blank.attachment_scene:
		hover_vis.flash_red()
		return false
	return false
