extends Control

onready var intro:Control = $Intro
onready var shiftstats:Control = $ShiftStats
onready var hellorobot:Control = $HelloRobot
onready var gameover:Control = $GameOver
onready var loopcontroller: Node = get_node("/root/Game/GameLoopController")

signal any_key_pressed()

var bar_is_shown:bool = false

func _ready():
	self.visible = false
	shiftstats.visible = false
	intro.visible = false
	hellorobot.visible = false
	gameover.visible = false

func _input(event):
	if event is InputEventKey and bar_is_shown:
		emit_signal("any_key_pressed")

func shift_stats_screen():
	# asking loop controller for stats, shows them
	print("shift_stats called")
#	bar_is_shown = true
#	get_node("ShiftStats/Label").text = "Hello there!"
#	self.visible = true
#	shiftstats.visible = true
#	yield(self,"any_key_pressed")


func gameover_screen():
	pass

func hellorobot():
	pass

func intro():
	pass
