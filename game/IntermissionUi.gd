extends Control

signal dismissed()

onready var shiftstats:Control = $ShiftStats
onready var hellorobot:Control = $IntroRobot
onready var gameover:Control = $GameOver
onready var loopcontroller: Node = get_node("/root/Game/GameLoopController")

func _ready():
	reset()

func shift_stats_screen():
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
	$ShiftStats/NextShift.grab_focus()

func gameover_screen():
	get_node("GameOver/GamoverMultiline").bbcode_text = (
		"[color=#ff6020]You're officially too slow! After [b]" + str(loopcontroller.shift_number) + "[/b] shifts, you're fired![/color]" +
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
	$GameOver/ExitToMenu.grab_focus()

func hellorobot_screen():
	get_node("IntroRobot/AboutRobot").bbcode_text = (
		"Please welcome:" +
		"\nOur newest hire and latest addition to the factory floor, the 6DoF Assembly Line Robot!" +
		"\n\nWorkers not able to keep up with the robot's pace will be made redundant. Good luck!"
	)
	self.visible = true
	hellorobot.visible = true
	$IntroRobot/Proceed.grab_focus()

func _on_Button_pressed():
	Sound.play("GUI Proceed")
	emit_signal("dismissed")

func reset():
	self.visible = false
	shiftstats.visible = false
	hellorobot.visible = false
	gameover.visible = false
