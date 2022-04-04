extends Control

onready var intro:Control = $Intro
onready var shiftstats:Control = $ShiftStats
onready var hellorobot:Control = $HelloRobot
onready var gameover:Control = $GameOver
onready var loopcontroller: Node = get_node("/root/Game/GameLoopController")

var is_shown:bool = false

func _ready():
	self.visible = false
	shiftstats.visible = false
	intro.visible = false
	hellorobot.visible = false
	gameover.visible = false

func _input(event):
	if event is InputEventKey and is_shown:
		pass

func _process(delta):
	if is_shown:
		pass


func shift_stats_screen():
	# asking loop controller for stats, shows them
	get_node("ShiftStats/Label").text = "Hello there!"
	self.visible = true
	shiftstats.visible = true


func gameover_screen():
	pass

func hellorobot():
	pass

func intro():
	pass
