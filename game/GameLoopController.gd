extends Node

# TODO
# - add signals for essential events
# - improve the timer stuff
# - refactor some mess between _process and procedural stages (it works actually)
# - public func to adjust robot's speed maybe.

signal spawn_first_assembly()
signal stop_production()

onready var transition_screen: TransitionScreen = get_node("/root/Game/UI/TransitionScreen")

# TESTING / PROTOTYPING VARIABLES
var money_for_one_blank:int = 100
var money_for_fully_assembled_base_multiplier:int = 3
var money_to_pass_shift = money_for_one_blank * 1

# GAMEPLAY
export(float, 1, 4, 0.01) var robot_speed
export(float, 1, 8, 0.01) var median_assembly_time
var assembly_line_works:bool
var shift_number:int
export var points_treshold = 20
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
var robot_assembled_current_shift:int = 0
var money_current_shift:int = 0

var player_attachments_total:int = 0
var player_assembled_total:int = 0
var robot_assembled_total:int = 0
var money_total:int = 0

# Sound
var shift_music: Sound.EvInstance

func _ready():
	shift_timer.wait_time = shift_time_limit
	shift_music = Sound.instance("Music Gameplay")
	self.connect("finished_assembly", self, "finished_assembly")

func shifts_init():
	_zeroing_variables()
	_introduction()
	_shift_start()

func _shift_start():
	_zeroing_shift_variables()
	transition_screen.fade_out()
	shift_number += 1

	print("\n-- start of ",shift_number," shift --")
	print("Assemble as much as possible devices in ", shift_time_limit, " seconds.")

	assembly_line_works = true

	shift_timer.start()
	time_left = 0

	shift_music.param("Speedup", clamp(0.1 * (shift_number - 1), 0.0, 1.0)).start()

	# Delay first incoming assemblies
	yield(get_tree().create_timer(5.0), "timeout")

	emit_signal("spawn_first_assembly")

func _shift_end():
	shift_music.stop()
	emit_signal("stop_production")
	transition_screen.fade_in()

	print("-- end of ",shift_number," shift --")
	assembly_line_works = false

	_stats_after_shift()
#	_win_lose_check()

	# temp.overwriting is_lose for prototyping purposes
	if money_current_shift < money_to_pass_shift:
		is_lose = true
	print("is_lose: ", is_lose)
	# this snippet above might be deleted after improving other part

	if is_lose:
		_gameover()
	else:
		var game_node:Node = get_node("/root/Game")
		game_node.unload_level()
		yield(get_tree().create_timer(1.0), "timeout")
		game_node.load_level()
#		emit_signal("spawn_first_assembly")
#		print ("emitted signal: 'spawn_first_assembly'")
		print ("starting shift...")
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
	print("SHIFTS SURVIVED: ", shift_number)
	print("FULLY ASSEMBLED: ", player_assembled_total)
	print("MONEY EARNED: ", money_total)
	Sound.instance("YouLost").attach(self).start()

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
	player_attachments_total += player_attachments_current_shift
	robot_assembled_total += robot_assembled_current_shift
	money_total += money_current_shift

	print("\nSHIFT RESULTS:")
	print("Attached: ", player_attachments_current_shift," blanks.")
	print("Assembled: ", player_assembled_current_shift," models")
	print("Robot assembled: ", robot_assembled_current_shift," models.")

	print("\nOVERALL RESULTS:")
	print("Assembled: ", player_assembled_total," models total.")
	print("Attached: ", player_attachments_total," blanks total.")
	print("Robot assembled: ", robot_assembled_total," models total.")

	print("\nYou earned ", money_current_shift, " today.")
	print("Your total earnings: ", money_total)

func _zeroing_variables():
	player_assembled_current_shift = 0
	robot_assembled_current_shift = 0
	player_assembled_total = 0
	robot_assembled_total = 0
	player_attachments_current_shift = 0
	player_attachments_total = 0
	money_current_shift = 0
	money_total = 0
	shift_number = 0
	is_lose = false
	assembly_line_works = false

func _zeroing_shift_variables():
	player_assembled_current_shift = 0
	player_attachments_current_shift = 0
	robot_assembled_current_shift = 0
	money_current_shift = 0
	assembly_line_works = false

func _load_next_shift():
	var game_node:Node = get_node("/root/Game")
	game_node.load_level()

	emit_signal("spawn_first_assembly")
	_shift_start()


#############################################
#     P U B L I C     F U N C T I O N S     #
#############################################

func get_stats(what):
	print("SUCCESFULLY CALLED get_stats() from GameLoopController")
#	match what:


func finished_assembly(num_connectors: int, num_attachments: int) -> void:

	print("yeet " + str(num_attachments) + "/" + str(num_connectors))

	player_attachments_current_shift += num_attachments
	add_money(num_attachments * money_for_one_blank)
	if num_attachments == num_connectors:
		add_money(num_connectors * money_for_one_blank * money_for_fully_assembled_base_multiplier)
		add_assembly("player")

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
