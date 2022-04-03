extends Spatial

const WHITE_MATERIAL: Material = preload("res://objects/extras/HoverVisWhiteMaterial.tres")
const RED_MATERIAL: Material = preload("res://objects/extras/HoverVisRedMaterial.tres")

onready var flash_timer: Timer = $FlashTimer

var flashes: int = 0

func _ready() -> void:
	flash_timer.connect("timeout", self, "timer_timeout")

func flash_red() -> void:
	flash_timer.stop()
	flashes = 0
	$MeshInstance.set_surface_material(0, RED_MATERIAL)
	flash_timer.start()

func timer_timeout() -> void:
	flashes += 1
	match flashes:
		1:
			$MeshInstance.set_surface_material(0, WHITE_MATERIAL)
		2:
			$MeshInstance.set_surface_material(0, RED_MATERIAL)
		_:
			$MeshInstance.set_surface_material(0, WHITE_MATERIAL)
			flash_timer.stop()
