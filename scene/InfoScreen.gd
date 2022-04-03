tool
extends Spatial

export var display_material: Material setget set_display_material, get_display_material

func set_display_material(mat: Material) -> void:
	$InfoScreen/Screen.set_surface_material(1, mat)

func get_display_material() -> Material:
	return $InfoScreen/Screen.get_surface_material(1)
