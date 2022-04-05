extends Control

onready var intro:Control = $IntroGame
onready var shiftstats:Control = $ShiftStats
onready var hellorobot:Control = $IntroRobot
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

#player_attachments_current_shift
#player_assembled_current_shift
#player_money_current_shift
#robot_attachments_current_shift
#robot_assembled_current_shift
#robot_money_current_shift
#player_grade_last_assembly
#player_grade_current_shift
#robot_grade_last_assembly
#robot_grade_current_shift
#
#player_attachments_total
#player_assembled_total
#player_money_total
#robot_assembled_total
#robot_money_total

func shift_stats_screen():
	print("shift_stats_screen() called")
	bar_is_shown = true
	get_node("ShiftStats/StatsMultiline").text = (
		"Shifts count: " + str(loopcontroller.shift_number) +
		"\n\nSHIFT STATS:" +
		"\nCompleted assemblies: " + str(loopcontroller.player_assembled_current_shift) +
		"\nAttached details: " + str(loopcontroller.player_attachments_current_shift) +
		"\nTotal Earnings: " + str(loopcontroller.player_money_current_shift) +
		"\n\nTOTAL STATS:" +
		"\nCompleted assemblies: " + str(loopcontroller.player_assembled_total) +
		"\nAttached details: " + str(loopcontroller.player_attachments_total) +
		"\nTotal Earnings: " + str(loopcontroller.player_money_total)
		)

	get_node("ShiftStats/StatsMultiline").text += (
		"\n\nROBOT STATS (shift)\n" +
		"\nCompleted assemblies: " + str(loopcontroller.robot_assembled_current_shift) +
		"\nAttached details: " + str(loopcontroller.robot_attachments_current_shift) +
		"\nTotal Earnings: " + str(loopcontroller.robot_money_current_shift) +
		"\n\nTOTAL STATS:" +
		"\nCompleted assemblies: " + str(loopcontroller.robot_assembled_total) +
		"\nAttached details: " + str(loopcontroller.robot_attachments_total) +
		"\nTotal Earnings: " + str(loopcontroller.robot_money_total)
		)
	self.visible = true
	shiftstats.visible = true


func gameover_screen():
	print("gameover_screen() called")
	bar_is_shown = true
	get_node("GameOver/GamoverMultiline").text = (
		"--- GAME OVER! ---\n\n" +
		"Shifts count: " + str(loopcontroller.shift_number) +
		"\n\nSHIFT STATS:" +
		"\nCompleted assemblies: " + str(loopcontroller.player_assembled_current_shift) +
		"\nAttached details: " + str(loopcontroller.player_attachments_current_shift) +
		"\nTotal Earnings: " + str(loopcontroller.player_money_current_shift) +
		"\n\nTOTAL STATS:" +
		"\nCompleted assemblies: " + str(loopcontroller.player_assembled_total) +
		"\nAttached details: " + str(loopcontroller.player_attachments_total) +
		"\nTotal Earnings: " + str(loopcontroller.player_money_total)
		)
	get_node("GameOver/GamoverMultiline").text += (
		"\n\nROBOT STATS (shift)\n" +
		"\nCompleted assemblies: " + str(loopcontroller.robot_assembled_current_shift) +
		"\nAttached details: " + str(loopcontroller.robot_attachments_current_shift) +
		"\nTotal Earnings: " + str(loopcontroller.robot_money_current_shift) +
		"\n\nTOTAL STATS:" +
		"\nCompleted assemblies: " + str(loopcontroller.robot_assembled_total) +
		"\nAttached details: " + str(loopcontroller.robot_attachments_total) +
		"\nTotal Earnings: " + str(loopcontroller.robot_money_total)
		)
	self.visible = true
	gameover.visible = true

func hellorobot_screen():
	bar_is_shown = true
	get_node("IntroRobot/AboutRobot").text = ("--- Hello Robot! ---")
	self.visible = true
	hellorobot.visible = true

func intro():
	pass

func _on_Button_pressed():
	emit_signal("any_key_pressed")
	Sound.instance("Drill GUI 2").attach(self).start()
