class_name Game
extends Node

export var level_scene: PackedScene

export(NodePath) var loop_controller_path
onready var loop_controller: Node = get_node(loop_controller_path)

onready var main_menu: Control = $UI/MainMenu
onready var loading_screen: TransitionScreen = $UI/LoadingScreen
onready var loading_background: Control = $UI/LoadingBackground
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
	loading_screen.connect("loading_done", self, "loading_done")

func _process(delta: float) -> void:
	DebugOverlay.display("fps %d" % Performance.get_monitor(Performance.TIME_FPS))

	if Input.is_action_just_pressed("menu"):
		on_return_to_menu()

func loading_done() -> void:
	loading_background.hide()
	DebugOverlay.label.show()
	main_menu.start()

func on_start_game() -> void:
	transition_screen.fade_in()
	yield(get_tree().create_timer(0.5), "timeout")
	main_menu.hide()
	load_level()
	loop_controller.shifts_init()

func on_return_to_menu() -> void:
	loop_controller.return_to_menu()

func back_to_menu() -> void:
	unload_level()
	main_menu.start()

func unload_level() -> void:
	if level:
		level_container.remove_child(level)
		level.queue_free()
		level = null

func load_level() -> void:
	level = level_scene.instance()
	level_container.add_child(level)
	loop_controller.connect("spawn_first_assembly", level.get_node("Room/Conveyor"), "spawn_assembly")
	loop_controller.connect("stop_production", level.get_node("Room/Conveyor"), "stop_production")
	level.get_node("Room/Conveyor").connect("finished_assembly", loop_controller, "finished_assembly")
