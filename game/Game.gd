# Copyright 2021 Outfrost
# This work is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the LICENSE file for more details.

class_name Game
extends Node

export var level_scene: PackedScene

onready var main_menu: Control = $UI/MainMenu
onready var transition_screen: TransitionScreen = $UI/TransitionScreen
onready var level_container: Spatial = $LevelContainer

var level: Spatial

var debug: Reference

func _ready() -> void:
	if OS.has_feature("debug"):
		var debug_script = load("res://debug.gd")
		if debug_script:
			debug = debug_script.new(self)
			debug.startup()

	main_menu.connect("start_game", self, "on_start_game")

func _process(delta: float) -> void:
	DebugOverlay.display("fps %d" % Performance.get_monitor(Performance.TIME_FPS))

	if Input.is_action_just_pressed("menu"):
		back_to_menu()

func on_start_game() -> void:
	main_menu.hide()
	level = level_scene.instance()
	level_container.add_child(level)

func back_to_menu() -> void:
	if level:
		level_container.remove_child(level)
		level.queue_free()
		level = null
	main_menu.show()
