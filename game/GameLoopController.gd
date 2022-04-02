extends Node

export var shift_time_limit = 5 #seconds
export var points_treshold = 20
export var shift_number = 0
export(float, 1, 4, 0.01) var robot_speed
export(float, 1, 8, 0.01) var median_assembly_time


var timer = Timer.new()

var assembly_line_works:bool = false
var time_shift_started:int = 0
var time_shift_passed:int = 0

var is_lose:bool = false

var player_assembled_current_shift:int = 0
var robot_assembled_current_shift:int = 0

var player_assembled_total:int = 0
var robot_assembled_total:int = 0

var money_current_shift = 0
var money_total = 0

#func _ready():
#	pass

func shifts_init():
	if shift_number == 0:
		_introduction()
		
	_shift_start()

func _shift_start():
	shift_number += 1
	print("\n-- start of ",shift_number," shift --")
	print("Your shift started! You have ", shift_time_limit, " seconds.")
	
	time_shift_started = OS.get_ticks_msec()
	assembly_line_works = true

func _shift_end():
	print("-- end of ",shift_number," shift --")
	assembly_line_works = false
	
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
	
	# WIN-LOSE CHECK
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
		
	
	money_total += money_current_shift
	print("\nYou earned ", money_current_shift, " today.")
	print("Your total earnings: ", money_total)
	money_current_shift = 0
	
	is_lose = _check_for_lose()
	print("\nLOSE STATE: ", is_lose)
	
	if is_lose:
		_gameover()
	else:
		_shift_start()
	
func _check_for_lose():
	# dummy yes/no result
	randomize()
	return randi()%2

func _shift_running():
	pass
	

func _gameover():
	print("GAME OVER! +stats and outro")

func _introduction():
	print("\nWE READ THE INTRO:\n",
			"- HOW ROBOTS OUTPLAY HUMANS.\n",
			"- HOW WE CAN COMPETE WITH ROBOT TO STAY EMPLOYED.\n",
			"- ABOUT CONTROLS. GOOD LUCK!\n")

func add_assembly(recipient:String  = 'undefined'):
	if recipient == "player":
		player_assembled_current_shift += 1
	if recipient == "robot":
		robot_assembled_current_shift += 1
	if recipient != "player" and recipient != "robot":
		print("ERROR: undefined recipient in the 'add_assembly' func.")

func add_money(some_variable:int = 100):
	money_current_shift += some_variable

func _process(delta):
	if assembly_line_works:
		time_shift_passed = OS.get_ticks_msec() - time_shift_started
		
		if time_shift_passed >= shift_time_limit * 1000:
			assembly_line_works = false
			_shift_end()
	
func _seconds_counter():
	pass

func _dummy_assembly_process():
	pass
