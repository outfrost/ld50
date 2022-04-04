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
var money_to_pass_shift = money_for_one_blank * 0

# GAMEPLAY
export(float, 1, 4, 0.01) var robot_speed
export(float, 1, 8, 0.01) var median_assembly_time
var assembly_line_works:bool
var shift_number:int
export var points_treshold = 5000
var is_lose:bool

# ASSEMBLY LINE TIMING STUFF
export var shift_time_limit:int = 60 #seconds
var time_left:int #must be in seconds
var time_left_prev:int #must be in seconds
var time_shift_started:int = 0
var time_shift_passed:int = 0

export(NodePath) var shift_timer_path
onready var shift_timer: Node = get_node(shift_timer_path)

# STATS
var player_attachments_current_shift:int = 0
var player_assembled_current_shift:int = 0
var player_money_current_shift:int = 0
var robot_assembled_current_shift:int = 0
var robot_money_current_shift:int = 0
var player_grade_last_assembly:float = 0.0
var player_grade_current_shift:float = 0.0
var robot_grade_last_assembly:float = 0.0
var robot_grade_current_shift:float = 0.0

var player_attachments_total:int = 0
var player_assembled_total:int = 0
var player_money_total:int = 0
var robot_assembled_total:int = 0
var robot_money_total:int = 0

# Sound
var shift_music: Sound.EvInstance

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
	assembly_line_works = true
	shift_timer.start()
	time_left = 0

	print("\n-- start of ",shift_number," shift --")
	print("Assemble as much as possible devices in ", shift_time_limit, " seconds.")

	shift_music.param("Speedup", clamp(0.1 * (shift_number - 1), 0.0, 1.0)).start()
	transition_screen.fade_out()

	# Delay first incoming assemblies
	yield(get_tree().create_timer(3.0), "timeout")
	emit_signal("spawn_first_assembly")

func _shift_end():
	print("-- end of ",shift_number," shift --")
	shift_music.stop()
	emit_signal("stop_production")
	assembly_line_works = false

	_calculate_shift_stats()
	_win_lose_check()
	transition_screen.fade_in()

	if is_lose:
		_unload_level()
		_gameover()
	else:
		_unload_level()
		_shift_stats_screen()
		_load_level()
		_shift_start()

func _win_lose_check():
	if simplified_win_lose:
		if player_money_current_shift < money_to_pass_shift:
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

func _shift_running():
	pass

func _introduction():
	print("\nWE READ THE INTRO:\n",
			"- HOW ROBOTS OUTPLAY HUMANS.\n",
			"- HOW WE CAN COMPETE WITH ROBOT TO STAY EMPLOYED.\n",
			"- ABOUT CONTROLS. GOOD LUCK!\n")

func _gameover():
	print("\nGAME OVER!")
	print("SHIFTS SURVIVED: ", shift_number)
	print("FULLY ASSEMBLED: ", player_assembled_total)
	print("MONEY EARNED: ", player_money_total)
	Sound.instance("YouLost").attach(self).start()

func _input(event):
	if event is InputEventKey and !assembly_line_works:
		emit_signal("any_key_pressed")
		print("'any_key_pressed' inside GameLoopController")

func _process(delta):

	# assembly line kicks in
	if assembly_line_works:
		_seconds_counter()

func _seconds_counter():
	time_left = floor(shift_timer.get_time_left())
	if time_left != time_left_prev:
		print(time_left," seconds left")
	time_left_prev = time_left

func _dummy_assembly_process():
	pass

func _on_ShiftTimer_timeout():
	pass # Not used because signal directly spawns _shift_end() function.

func _calculate_shift_stats():

	player_assembled_total += player_assembled_current_shift
	player_attachments_total += player_attachments_current_shift
	player_money_total += player_money_current_shift
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
	player_money_total = 0
	robot_money_total = 0
	shift_number = 0
	is_lose = false
	emit_signal("stats_updated")

func _zeroing_shift_variables():
	player_assembled_current_shift = 0
	player_attachments_current_shift = 0
	player_money_current_shift = 0
	robot_assembled_current_shift = 0
	robot_money_current_shift = 0
	assembly_line_works = false
	emit_signal("stats_updated")

func _unload_level():
	var game_node:Node = get_node("/root/Game")
	game_node.unload_level()
	yield(get_tree().create_timer(1.0), "timeout")

func _load_level():
	var game_node:Node = get_node("/root/Game")
	game_node.load_level()

func _shift_stats_screen():
	transition_screen.fade_out()
	var node:Control = get_node("/root/Game/UI/InfoScreens")
	yield(node,"any_key_pressed")
	transition_screen.fade_in()
	pass


#############################################
#     P U B L I C     F U N C T I O N S     #
#############################################

func get_stats(what):
	print("SUCCESFULLY CALLED get_stats() from GameLoopController")

func finished_assembly(num_connectors: int, num_attachments: int) -> void:
#	print("yeet " + str(num_attachments) + "/" + str(num_connectors))

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
