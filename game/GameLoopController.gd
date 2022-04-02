extends Node

export var shift_time_limit = 240
export var start_game = true
export var points_treshold = 20
export var shift_number = 0
export(float, 1, 4, 0.01) var robot_speed
export(float, 1, 8, 0.01) var median_assembly_time


var timer = Timer.new()
var is_lose:bool = false

var player_assembled_current_shift:int = 0
var robot_assembled_current_shift:int = 0
var money_current_shift = 0

var player_assembled_total:int = 0
var robot_assembled_total:int = 0
var money_total = 0

#func _ready():
#	pass

func shifts_loop():
	if shift_number == 0:
		introduction()
		
	while not is_lose:
		shift_start()
		dummy_assembly_process()
		shift_end()
	
	if is_lose:
		gameover()

func shift_start():
	shift_number += 1
	print("-- 'start of your ",shift_number," shift' animation --")
	print("Your shift started! You have ", shift_time_limit, " seconds.")
	
	# dummy assembly process with dummy timer

func shift_end():
	print("-- 'end of the shift' animation --")
	
	is_lose = check_for_lose()
	print("LOSE STATE: ", is_lose)
	
func check_for_lose():
	
	# dummy yes/no result
	randomize()
	return randi()%2

func dummy_assembly_process():
	pass

func gameover():
	print("GAME OVER! +stats and outro")

func introduction():
	print("WE HAVE READ THE INTRO ABOUT HOW ROBOTS OUTPLAY HUMANS.")
	print("WE HAVE READ HOW WE CAN COMPETE WITH ROBOT AND STAY EMPLOYED.")
	print("WE HAVE READ ABOUT CONTROLS. GOOD LUCK!")
	start_game = false


func _process(delta):
	pass
