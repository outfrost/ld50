extends Control

onready var intro:Control = $Intro
onready var hellorobot:Control = $HelloRobot
onready var shiftstats:Control = $ShiftStats
onready var gameover:Control = $GameOver
onready var loopcontroller: Node = get_node("/root/Game/GameLoopController")

var is_shown:bool = false

func _ready():
	self.visible = false

func stats_after_shift():
	# asking loop controller for stats, shows them
	pass

func gameover_screen():
	pass
