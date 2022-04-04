class_name Game
extends Node

export var level_scene: PackedScene

export(NodePath) var loop_controller_path
onready var loop_controller: Node = get_node(loop_controller_path)

onready var main_menu: Control = $UI/MainMenu
onready var transition_screen: TransitionScreen = $UI/TransitionScreen
onready var level_container: Spatial = $LevelContainer

var level: Spatial

var debug: Reference

func _ready() -> void:
	randomize()

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
	transition_screen.fade_in()
	yield(get_tree().create_timer(0.5), "timeout")
	main_menu.hide()
	load_level()
	loop_controller.shifts_init()

func back_to_menu() -> void:
	unload_level()
	main_menu.show()

func unload_level() -> void:
	if level:
		level_container.remove_child(level)
		level.queue_free()
		level = null
		print("level unloaded")

func load_level() -> void:
	level = level_scene.instance()
	level_container.add_child(level)
	loop_controller.connect("spawn_first_assembly", level.get_node("Room/Conveyor"), "spawn_assembly")
	loop_controller.connect("stop_production", level.get_node("Room/Conveyor"), "stop_production")
	level.get_node("Room/Conveyor").connect("finished_assembly", loop_controller, "finished_assembly")
	print ("level loaded")
