extends Node

# TODO
# - add signals for essential events
# - improve the timer stuff
# - refactor some mess between _process and procedural stages (it works actually)
# - public func to adjust robot's speed maybe.

signal spawn_first_assembly()
signal stop_production()
signal stats_updated()

onready var transition_screen: TransitionScreen = get_node("/root/Game/UI/TransitionScreen")

# TESTING / PROTOTYPING VARIABLES
var simplified_win_lose:bool = true
var money_for_one_blank:int = 100
var money_for_fully_assembled_base_multiplier:int = 3
var attaches_to_pass_shift = 0 # set 0 if need to pass all shifts
var robot_initial_skill_bonus:int = 20 # zero means no bonus

# GAMEPLAY
export(float, 1, 4, 0.01) var robot_speed
export(float, 1, 8, 0.01) var median_assembly_time
var assembly_line_works:bool
var shift_number:int
export var points_treshold = 5000
var is_lose:bool
var robot_skill:int = 0

# ASSEMBLY LINE TIMING STUFF
export var shift_time_limit:int = 60 #seconds
var time_left:int #must be in seconds
var time_left_prev:int #must be in seconds
var time_shift_started:int = 0
var time_shift_passed:int = 0

export(NodePath) var shift_timer_path
onready var shift_timer: Node = get_node(shift_timer_path)

export(NodePath) var robot_timer_path
onready var robot_timer: Timer = get_node(robot_timer_path)

# STATS
var player_attachments_current_shift:int = 0
var player_assembled_current_shift:int = 0
var player_money_current_shift:int = 0
var robot_attachments_current_shift:int = 0
var robot_assembled_current_shift:int = 0
var robot_money_current_shift:int = 0
var player_grade_last_assembly:float = 0.0
var player_grade_current_shift:float = 0.0
var robot_grade_last_assembly:float = 0.0
var robot_grade_current_shift:float = 0.0

var player_attachments_total:int = 0
var player_assembled_total:int = 0
var player_money_total:int = 0
var robot_attachments_total:int = 0
var robot_assembled_total:int = 0
var robot_money_total:int = 0

# Sound
var shift_music: Sound.EvInstance

# Notifications
var said_halftime: bool = false

func _ready():
	shift_timer.wait_time = shift_time_limit
	shift_music = Sound.instance("Music Gameplay")

func shifts_init():
	_zeroing_main_variables()
	_introduction()
	_shift_start()

func _shift_start():
	_zeroing_shift_variables()
	shift_number += 1

	if shift_number >= 2:
		robot_skill = shift_number - 1 + robot_initial_skill_bonus
		robot_timer.wait_time = 60 / robot_skill
		robot_timer.start()


	print("current Robot Skill: ",robot_skill)
	assembly_line_works = true
	shift_timer.start()
	time_left = 0

	print("\n-- start of ",shift_number," shift --")
	print("Assemble as much as possible devices in ", shift_time_limit, " seconds.")

	shift_music.param("Speedup", clamp(0.1 * (shift_number - 1), 0.0, 1.0)).start()
	transition_screen.fade_out()

	yield(get_tree().create_timer(2.0), "timeout")
	if shift_number == 1:
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

	# Delay first incoming assemblies
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal("spawn_first_assembly")

func _shift_end():
	print("-- end of ",shift_number," shift --")
	shift_music.stop()
	emit_signal("stop_production")
	assembly_line_works = false
	robot_timer.stop()

	_calculate_shift_stats()
	_win_lose_check()
	transition_screen.fade_in()
	yield(get_tree().create_timer(0.5), "timeout")

	if is_lose:
		_unload_level()
		_gameover()
	else:
		_unload_level()
		_intermission()

func _win_lose_check():
	if simplified_win_lose:
		if player_attachments_current_shift < attaches_to_pass_shift:
			is_lose = true
		print("\nis_lose: ", is_lose, "\n")
	else:
		if robot_money_total > player_money_total:
			if (robot_money_total-player_money_total) >= points_treshold:
				print("You have fired!")
				is_lose = true
			else:
				print ("Work faster, or you will be fired!")
		elif robot_money_total < player_money_total:
			print("Congrats! You are ahead of robot!")
		else:
			print("You are neck-and-neck with robot! Work faster!")


func _input(event):
	if event is InputEventKey and !assembly_line_works:
		emit_signal("any_key_pressed")
		print("'any_key_pressed' inside GameLoopController")

func _process(delta):

	# assembly line kicks in
	if assembly_line_works:
		_seconds_counter()

		if !said_halftime && shift_timer.time_left < (shift_timer.wait_time * 0.5):
			said_halftime = true
			Notification.push(
				"Shift Supervisor",
				"Only halfway through the shift. Keep going!"
			)

func _seconds_counter():
	time_left = floor(shift_timer.get_time_left())
	if time_left != time_left_prev:
#		print(time_left," seconds left")
		pass
	time_left_prev = time_left

func _on_ShiftTimer_timeout():
	pass # Not used because signal directly spawns _shift_end() function.

func _calculate_shift_stats():

	player_assembled_total += player_assembled_current_shift
	player_attachments_total += player_attachments_current_shift
	player_money_total += player_money_current_shift
	player_attachments_total += robot_attachments_current_shift
	robot_assembled_total += robot_assembled_current_shift
	robot_money_total += robot_money_current_shift


	print("\nPLAYER SHIFT RESULTS:")
	print("Attached: ", player_attachments_current_shift," blanks.")
	print("Assembled: ", player_assembled_current_shift," models")
	print("Earned: ", player_money_current_shift, " scores.")

	print("\nROBOT SHIFT RESULTS:")
	print("Robot assembled: ", robot_assembled_current_shift," models.")
	print("Robot earned: ", player_money_current_shift, " scores.")

	print("\nOVERALL PLAYER RESULTS:")
	print("Attached: ", player_attachments_total," blanks total.")
	print("Assembled: ", player_assembled_total," models total.")
	print("Earned: ", player_money_total, " scores total.")

	print("\nOVERALL ROBOT RESULTS:")
	print("Assembled: ", robot_assembled_total," models total.")
	print("Earned: ", robot_money_total, " scores total.")


func _zeroing_main_variables():
	player_assembled_total = 0
	robot_assembled_total = 0
	player_attachments_total = 0
	robot_attachments_total = 0
	player_money_total = 0
	robot_money_total = 0
	shift_number = 0
	is_lose = false
	emit_signal("stats_updated")

func _zeroing_shift_variables():
	player_attachments_current_shift = 0
	player_assembled_current_shift = 0
	player_money_current_shift = 0
	robot_attachments_current_shift = 0
	robot_assembled_current_shift = 0
	robot_money_current_shift = 0
	assembly_line_works = false
	said_halftime = false
	emit_signal("stats_updated")

func _unload_level():
	var game_node:Node = get_node("/root/Game")
	game_node.unload_level()
	yield(get_tree().create_timer(1.0), "timeout")

func _load_level():
	var game_node:Node = get_node("/root/Game")
	game_node.load_level()

func _introduction():
	print("Dummy INTRODUCTION")

func _intermission():
	var node:Control = get_node("/root/Game/UI/InfoScreens")
	node.shift_stats_screen()
	transition_screen.fade_out()
	yield(transition_screen, "animation_finished")
	yield(node,"any_key_pressed")
	transition_screen.fade_in()
	yield(transition_screen, "animation_finished")
	node.shiftstats.visible = false
	node.bar_is_shown = false
	node.hide()

	if shift_number == 1:
		_hello_robot()
	else:
		_load_level()
		_shift_start()

func _hello_robot():
	print("spawning of robot welcome screen")
	var node:Control = get_node("/root/Game/UI/InfoScreens")
	node.hellorobot_screen()
	transition_screen.fade_out()
	yield(transition_screen, "animation_finished")
	yield(node,"any_key_pressed")
	transition_screen.fade_in()
	yield(transition_screen, "animation_finished")
	node.hellorobot.visible = false
	node.bar_is_shown = false
	node.hide()
	_load_level()
	_shift_start()

func _gameover():
	print("\n--- GAME OVER! ---\n")
	Sound.play("YouLost")
	transition_screen.fade_out()
	var node:Control = get_node("/root/Game/UI/InfoScreens")
	node.gameover_screen()
	yield(node,"any_key_pressed")

	transition_screen.fade_in()
	yield(transition_screen, "animation_finished")
	node.gameover.visible = false
	node.bar_is_shown = false
	node.hide()
	get_node("/root/Game").back_to_menu()
	transition_screen.fade_out()

func _on_RobotTimer_timeout():
	if assembly_line_works:
		#roll base model size
		var base_model_size = randi()%10+1
		#how many robot will attach?
		var how_many_attachments:int
		if robot_skill < base_model_size:
			how_many_attachments = randi()%int(base_model_size)+1
		else:
			how_many_attachments = base_model_size

		robot_attachments_current_shift += how_many_attachments
		print("~~~ Robot: I just attached ",how_many_attachments," details!")
		add_money("robot",how_many_attachments * money_for_one_blank)

		if how_many_attachments == base_model_size:
				add_assembly("robot")
				add_money("robot",base_model_size * money_for_one_blank * money_for_fully_assembled_base_multiplier)
				print("~~~ Robot: I have fully assembled base!")
		robot_timer.start()

		emit_signal("robot_assembly_done")


#############################################
#     P U B L I C     F U N C T I O N S     #
#############################################

func return_to_menu() -> void:
	shift_timer.stop()
	shift_music.stop()
	emit_signal("stop_production")
	assembly_line_works = false
	transition_screen.fade_in()
	yield(transition_screen, "animation_finished")
	get_node("/root/Game").back_to_menu()
	transition_screen.fade_out()

func get_stats(what):
	print("SUCCESFULLY CALLED get_stats() from GameLoopController")

func finished_assembly(num_connectors: int, num_attachments: int) -> void:
#	print("yeet " + str(num_attachments) + "/" + str(num_connectors))
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

func add_assembly(recipient:String  = 'undefined'):
	if assembly_line_works:
		if recipient == "player":
			player_assembled_current_shift += 1
		if recipient == "robot":
			robot_assembled_current_shift += 1
		if recipient != "player" and recipient != "robot":
			print("ERROR: undefined recipient in the 'add_assembly' func.")
	else:
		print("ERROR. Can not add assembled counter: line is not working!")

func add_money(recipient:String="undefined",money_amount:int = 100):
	if assembly_line_works:
		match recipient:
			"player":
				player_money_current_shift += money_amount
			"robot":
				robot_money_current_shift += money_amount
			_: print("ERROR. Can not add money: Recipient is not defined!")
	else:
		print("ERROR. Can not add money: line is not working!")



