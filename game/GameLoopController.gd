extends Node

signal spawn_first_assembly()
signal stop_production()
signal stats_updated()

enum State {
	IDLE,
	SHIFT_LOADING,
	SHIFT_ONGOING,
	INTERMISSION_LOADING,
	INTERMISSION_ONGOING,
	ROBOT_INTRO_LOADING,
	ROBOT_INTRO_ONGOING,
	GAMEOVER_LOADING,
	GAMEOVER_ONGOING,
	RETURNING_TO_MENU,
}

onready var game: Game = find_parent("Game")
onready var transition_screen: TransitionScreen = game.get_node("UI/TransitionScreen")
onready var intermission_ui: Control = $IntermissionUi

var state = State.IDLE

# CORE STATS
const money_for_one_blank: int = 100
const money_for_fully_assembled_base_multiplier: int = 3
const robot_initial_skill_bonus: int = 0 # zero means no bonus
# If robot gets this far ahead in total, player loses
const points_treshold = 10000

# GAMEPLAY
var shift_number: int
var robot_skill:int = 0

# ASSEMBLY LINE TIMING STUFF
const shift_time_limit: int = 180 # seconds

export(NodePath) var shift_timer_path
onready var shift_timer: Node = get_node(shift_timer_path)

export(NodePath) var robot_timer_path
onready var robot_timer: Timer = get_node(robot_timer_path)

# STATS
var player_attachments_current_shift: int = 0
var player_assembled_current_shift: int = 0
var player_money_current_shift: int = 0
var robot_attachments_current_shift: int = 0
var robot_assembled_current_shift: int = 0
var robot_money_current_shift: int = 0
var player_grade_last_assembly: float = 0.0
var player_grade_current_shift: float = 0.0
var robot_grade_last_assembly: float = 0.0
var robot_grade_current_shift: float = 0.0

var player_attachments_total: int = 0
var player_assembled_total: int = 0
var player_money_total: int = 0
var robot_attachments_total: int = 0
var robot_assembled_total: int = 0
var robot_money_total: int = 0

# Sound
var shift_music: Sound.EvInstance
var shift_ambience: Sound.EvInstance

# Notifications
var said_halftime: bool = false

func _ready():
	shift_timer.wait_time = shift_time_limit
	shift_music = Sound.instance("Music Gameplay")
	shift_ambience = Sound.instance("Ambience")
	intermission_ui.connect("dismissed", self, "intermission_dismissed")
	transition_screen.connect("animation_finished", self, "transition_finished")

func _process(delta):
	if (
		state == State.SHIFT_ONGOING
		&& !said_halftime
		&& shift_timer.time_left < (shift_timer.wait_time * 0.5)
	):
		said_halftime = true
		Notification.push(
			"Shift Supervisor",
			"Only halfway through the shift. Keep going!"
		)

func shifts_init():
	reset_all()
	_shift_start()

func _shift_start():
	reset_shift()
	shift_number += 1
	Notification.reset()

	var conveyor = game.get_node("LevelContainer/Level/Room/Conveyor")

	if shift_number >= 2:
		robot_skill = shift_number - 1 + robot_initial_skill_bonus
		robot_timer.wait_time = 60 / robot_skill
		robot_timer.start()

	var max_part_index: int = 9
	if shift_number == 1:
		max_part_index = 2
	elif shift_number == 2:
		max_part_index = 3
	elif shift_number == 3:
		max_part_index = 4

	conveyor.set_difficulty_params(min(2 + shift_number, 16), 5 + shift_number, max_part_index)

	shift_timer.start()

	shift_music.param("Speedup", clamp(0.1 * (shift_number - 1), 0.0, 1.0)).start()
	shift_ambience.start()
	transition_screen.fade_out()

	yield(get_tree().create_timer(2.0), "timeout")
	if shift_number == 1:
		push_tutorial_messages()

	# Delay first incoming assemblies
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal("spawn_first_assembly")
	if shift_number >= 2:
		conveyor.start_robot()

func _shift_end():
	shift_music.stop()
	shift_ambience.stop()
	emit_signal("stop_production")
	robot_timer.stop()

	_calculate_shift_stats()

	if is_game_lost():
		_gameover()
	else:
		_intermission()

func push_tutorial_messages() -> void:
	Notification.push(
		"Manufacturing Assistant [BOT]",
		"This is your daily manufacturing process reminder.")
	Notification.push(
		"Manufacturing Assistant [BOT]",
		"Identify connectors on assembly. Click to grab part from appropriate bucket.")
	Notification.push(
		"Manufacturing Assistant [BOT]",
		"Rotate part using\n[Q] [W] [E] [A] [S] [D].")
	Notification.push(
		"Manufacturing Assistant [BOT]",
		"Click matching slot on assembly to attach part. Repeat.")
	Notification.push(
		"Manufacturing Assistant [BOT]",
		"When done, press green button to advance the conveyor belt.")
	Notification.push(
		"Manufacturing Assistant [BOT]",
		"Right click to place part back in the bucket.")
	Notification.push(
		"Manufacturing Assistant [BOT]",
		"Your performance will be evaluated at the end of your shift.")

func is_game_lost() -> bool:
	return (robot_money_total - player_money_total) >= points_treshold

func _calculate_shift_stats():
	player_assembled_total += player_assembled_current_shift
	player_attachments_total += player_attachments_current_shift
	player_money_total += player_money_current_shift
	robot_attachments_total += robot_attachments_current_shift
	robot_assembled_total += robot_assembled_current_shift
	robot_money_total += robot_money_current_shift

func reset_all():
	player_assembled_total = 0
	robot_assembled_total = 0
	player_attachments_total = 0
	robot_attachments_total = 0
	player_money_total = 0
	robot_money_total = 0
	shift_number = 0
	emit_signal("stats_updated")

func reset_shift():
	player_attachments_current_shift = 0
	player_assembled_current_shift = 0
	player_money_current_shift = 0
	robot_attachments_current_shift = 0
	robot_assembled_current_shift = 0
	robot_money_current_shift = 0
	player_grade_last_assembly = 0.0
	player_grade_current_shift = 0.0
	robot_grade_last_assembly = 0.0
	robot_grade_current_shift = 0.0
	said_halftime = false
	emit_signal("stats_updated")

func _intermission():
	state = State.INTERMISSION_LOADING
	transition_screen.fade_in()

func _gameover():
	state = State.GAMEOVER_LOADING
	transition_screen.fade_in()

func intermission_dismissed() -> void:
	match state:
		State.INTERMISSION_ONGOING:
			if shift_number == 1:
				state = State.ROBOT_INTRO_LOADING
			else:
				state = State.SHIFT_LOADING
			transition_screen.fade_in()
		State.ROBOT_INTRO_ONGOING:
			state = State.SHIFT_LOADING
			transition_screen.fade_in()
		State.GAMEOVER_ONGOING:
			state = State.RETURNING_TO_MENU
			transition_screen.fade_in()

func transition_finished() -> void:
	match state:
		State.SHIFT_LOADING:
			intermission_ui.reset()
			game.load_level()
			state = State.SHIFT_ONGOING
			_shift_start()
		State.INTERMISSION_LOADING:
			game.unload_level()
			intermission_ui.reset()
			intermission_ui.shift_stats_screen()
			state = State.INTERMISSION_ONGOING
			transition_screen.fade_out()
		State.ROBOT_INTRO_LOADING:
			intermission_ui.reset()
			intermission_ui.hellorobot_screen()
			state = State.ROBOT_INTRO_ONGOING
			transition_screen.fade_out()
		State.GAMEOVER_LOADING:
			game.unload_level()
			Sound.play("YouLost")
			intermission_ui.reset()
			intermission_ui.gameover_screen()
			state = State.GAMEOVER_ONGOING
			transition_screen.fade_out()
		State.RETURNING_TO_MENU:
			intermission_ui.reset()
			game.back_to_menu()
			state = State.IDLE
			transition_screen.fade_out()

func _on_RobotTimer_timeout():
	#roll base model size
	var base_model_size = randi()%16+1
	#how many robot will attach?
	var how_many_attachments:int
	if robot_skill < base_model_size:
		how_many_attachments = randi()%int(base_model_size)+1
	else:
		how_many_attachments = base_model_size

	robot_attachments_current_shift += how_many_attachments
	add_money("robot",how_many_attachments * money_for_one_blank)

	robot_grade_last_assembly = float(how_many_attachments) / float(base_model_size)
	robot_grade_current_shift = (
		(robot_grade_current_shift * robot_assembled_current_shift)
		+ robot_grade_last_assembly
	) / (robot_assembled_current_shift + 1)

	add_assembly("robot")
	if how_many_attachments == base_model_size:
		add_money("robot",base_model_size * money_for_one_blank * money_for_fully_assembled_base_multiplier)
	robot_timer.start()

	emit_signal("stats_updated")

#############################################
#     P U B L I C     F U N C T I O N S     #
#############################################

func return_to_menu() -> void:
	shift_timer.stop()
	shift_music.stop()
	shift_ambience.stop()
	shift_number = 0
	emit_signal("stop_production")
	state = State.RETURNING_TO_MENU
	transition_screen.fade_in()

func finished_assembly(num_connectors: int, num_attachments: int) -> void:
	Sound.play("Announcer")

	player_grade_last_assembly = float(num_attachments) / float(num_connectors)
	player_grade_current_shift = (
		(player_grade_current_shift * player_assembled_current_shift)
		+ player_grade_last_assembly
	) / (player_assembled_current_shift + 1)

	player_attachments_current_shift += num_attachments
	add_money("player",num_attachments * money_for_one_blank)
	if num_attachments == num_connectors:
		add_money("player",num_connectors * money_for_one_blank * money_for_fully_assembled_base_multiplier)
	add_assembly("player")

	emit_signal("stats_updated")

func add_assembly(recipient: String = "undefined"):
	match recipient:
		"player":
			player_assembled_current_shift += 1
		"robot":
			robot_assembled_current_shift += 1

func add_money(recipient: String = "undefined", money_amount: int = 100):
	match recipient:
		"player":
			player_money_current_shift += money_amount
		"robot":
			robot_money_current_shift += money_amount
