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
	get_node("ShiftStats/StatsMultiline").bbcode_text = (
		"End of shift [b]" + str(loopcontroller.shift_number) + "[/b]" +
		"\n\nYou finished [b]" + str(loopcontroller.player_assembled_current_shift) + "[/b] assemblies" +
		"\nYou attached [b]" + str(loopcontroller.player_attachments_current_shift) + "[/b] parts" +
		"\nToday's earnings: [b]" + str(loopcontroller.player_money_current_shift) + "¢[/b]" +
		"\n\nRobot finished [b]" + str(loopcontroller.robot_assembled_current_shift) + "[/b] assemblies" +
		"\nRobot attached [b]" + str(loopcontroller.robot_attachments_current_shift) + "[/b] parts" +
		"\nRobot would have earned: [b]" + str(loopcontroller.robot_money_current_shift) +"¢[/b]" +
		"\n\nTotal assemblies: [b]" + str(loopcontroller.player_assembled_total) + "[/b], compared to the robot's [b]" + str(loopcontroller.robot_assembled_total) + "[/b]" +
		"\nTotal attached parts: [b]" + str(loopcontroller.player_attachments_total) + "[/b], compared to the robot's [b]" + str(loopcontroller.robot_attachments_total) + "[/b]" +
		"\nTotal earnings: [b]" + str(loopcontroller.player_money_total) + "¢[/b] / Robot: [b]" + str(loopcontroller.robot_money_total) + "¢[/b]"
		)
	self.visible = true
	shiftstats.visible = true


func gameover_screen():
	print("gameover_screen() called")
	bar_is_shown = true
	get_node("GameOver/GamoverMultiline").bbcode_text = (
		"You're officially too slow! You're fired!" +
		"\n\nYou finished [b]" + str(loopcontroller.player_assembled_current_shift) + "[/b] assemblies" +
		"\nYou attached [b]" + str(loopcontroller.player_attachments_current_shift) + "[/b] parts" +
		"\nToday's earnings: [b]" + str(loopcontroller.player_money_current_shift) + "¢[/b]" +
		"\n\nRobot finished [b]" + str(loopcontroller.robot_assembled_current_shift) + "[/b] assemblies" +
		"\nRobot attached [b]" + str(loopcontroller.robot_attachments_current_shift) + "[/b] parts" +
		"\nRobot would have earned: [b]" + str(loopcontroller.robot_money_current_shift) +"¢[/b]" +
		"\n\nTotal assemblies: [b]" + str(loopcontroller.player_assembled_total) + "[/b], compared to the robot's [b]" + str(loopcontroller.robot_assembled_total) + "[/b]" +
		"\nTotal attached parts: [b]" + str(loopcontroller.player_attachments_total) + "[/b], compared to the robot's [b]" + str(loopcontroller.robot_attachments_total) + "[/b]" +
		"\nTotal earnings: [b]" + str(loopcontroller.player_money_total) + "¢[/b] / Robot: [b]" + str(loopcontroller.robot_money_total) + "¢[/b]"
		)
	self.visible = true
	gameover.visible = true

func hellorobot_screen():
	bar_is_shown = true
	get_node("IntroRobot/AboutRobot").bbcode_text = (
		"Please welcome:" +
		"\nOur newest hire and latest addition to the factory floor, the 6DoF Assembly Line Robot!" +
		"\n\nWorkers not able to keep up with the robot's pace will be made redundant. Good luck!"
	)
	self.visible = true
	hellorobot.visible = true

func intro():
	pass

func _on_Button_pressed():
	emit_signal("any_key_pressed")
	Sound.instance("GUI Proceed").attach(self).start()
