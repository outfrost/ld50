extends Node

# DESCRIPTION

# Purposes of this script:
# - handle gameplay entry point and the Introducion Story/Guidelines moment.
# - track game loops, track timing
# - provide information (stats, time left)
# - checking for win/lose conditions
# - adjusting the difficulty (robot speed, score gap)
# - emitting signals about essential changes (win/lose, shift started etc)
# - switching conditions between "procedural" and "_process" parts of game loop.

# PUBLIC FUNCTIONS:
# - add_assembly(string) // args: "robot" or "player" - adds scores point
# - add_money(int) // arg is currently the amount. May be implemented some other way.
# - shifts_init // called once as game starts

# VARIABLES, USEFUL AS PUBLIC:
# - time_left // seconds to the end of current shift
# - shift_time_limit // [exported] shift time limit in seconds

# TODO
# - add signals for essential events
# - improve the timer stuff
# - refactor some mess between _process and procedural stages (it works actually)
# - public func to adjust robot's speed maybe.
# - resetting gameplay variables in _shift_init()
# - what else must be public here?

# GAMEPLAY
export(float, 1, 4, 0.01) var robot_speed
export(float, 1, 8, 0.01) var median_assembly_time
var assembly_line_works:bool
var shift_number:int
export var points_treshold = 20
var is_lose:bool

# ASSEMBLY LINE TIMING STUFF
export var shift_time_limit:int = 5 #seconds
var time_left:int #must be in seconds
var time_left_prev:int #must be in seconds
var time_shift_started:int = 0
var time_shift_passed:int = 0

export(NodePath) var shift_timer_path
onready var shift_timer: Node = get_node(shift_timer_path)

# STATS
var player_assembled_current_shift:int = 0
var robot_assembled_current_shift:int = 0

var player_assembled_total:int = 0
var robot_assembled_total:int = 0

var money_current_shift:int = 0
var money_total:int = 0

# Sound
var shift_music: Sound.EvInstance

func _ready():
	shift_timer.wait_time = shift_time_limit
	shift_music = Sound.instance("Music Gameplay")
	# This event plays Music_1_v1 with an artificial (not musically-prepared) loop, to serve as a test dummy

func shifts_init():
	_zeroing_variables()
	_introduction()
	_shift_start()

func _shift_start():

	shift_number += 1
	print("\n-- start of ",shift_number," shift --")
	print("Assemble as much as possible devices in ", shift_time_limit, " seconds.")

	assembly_line_works = true
	shift_timer.start()
	time_left = 0

	shift_music.param("Music Gameplay", clamp(0.1 * (shift_number - 1), 0.0, 1.0)).start()

func _shift_end():
	shift_music.stop()

	print("-- end of ",shift_number," shift --")
	assembly_line_works = false
	_stats_after_shift()
#	_win_lose_check()

	# temp.overwriting is_lose for prototyping purposes
	randomize()
	is_lose = randi()%2 # dummy calc until real stats will work properly
	print("is_lose: ", is_lose)
	# this snippet above might be deleted after improving other part

	if is_lose:
		_gameover()
	else:
		_shift_start()

func _win_lose_check():
	if robot_assembled_total > player_assembled_total:
		if (robot_assembled_total-player_assembled_total) >= points_treshold:
			print("You have assembled ",
					robot_assembled_total - player_assembled_total,
					" models less than the Robot. You are fired!")
			is_lose = true
	elif robot_assembled_total < player_assembled_total:
		print("Congrats! You are ahead of robot for ",
				robot_assembled_total - player_assembled_total,
				" assembled models!")
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
	print("SHIFTS: ", shift_number)
	print("ASSEMBLED: ", player_assembled_total)
	print("EARNED: ", money_total)

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
	pass # Replace with function body.

func _stats_after_shift():

	player_assembled_total += player_assembled_current_shift
	robot_assembled_total += robot_assembled_current_shift

	print("\nSHIFT RESULTS:")
	print("Player: ", player_assembled_current_shift," models.")
	print("Robot: ", robot_assembled_current_shift," models.")
	print("\nOVERALL RESULTS:")
	print("Player: ", player_assembled_total," total.")
	print("Robot: ", robot_assembled_total," total.")

	player_assembled_current_shift = 0
	robot_assembled_current_shift = 0

	money_total += money_current_shift
	print("\nYou earned ", money_current_shift, " today.")
	print("Your total earnings: ", money_total)
	money_current_shift = 0

func _zeroing_variables():
	player_assembled_current_shift = 0
	robot_assembled_current_shift = 0
	player_assembled_total = 0
	robot_assembled_total = 0
	money_current_shift = 0
	money_total = 0
	shift_number = 0
	is_lose = false
	assembly_line_works = false




#############################################
#     P U B L I C     F U N C T I O N S     #
#############################################

func get_stats():
	pass

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

func add_money(some_variable:int = 100):
	if assembly_line_works:
		money_current_shift += some_variable
	else:
		print("ERROR. Can not add money: line is not working!")
