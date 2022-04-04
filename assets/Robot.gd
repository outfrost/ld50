extends Spatial

onready var anim: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

var robotworking_sound
var robotpoweron_sound

func _ready() -> void:
#	Sound.play("Robot", self)
	robotworking_sound = Sound.instance("RobotWorking").attach(self)
	Sound.instance("RobotPowerOn").attach(self).start()
#	robotpoweron_sound = Sound.instance("RobotPowerOn").attach(self).start()
	pass

func start_working() -> void:
	anim.travel("robotWorking")
	robotworking_sound.start()


func stop_working() -> void:
	anim.travel("robotDeactivate")
	robotworking_sound.stop()
	Sound.instance("RobotPowerOff").attach(self).start()

# Sound.instance("Robot").attach(self).start()
# Every instance of the Robot event triggers one of the three drill sounds
