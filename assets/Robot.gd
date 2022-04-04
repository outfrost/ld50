extends Spatial

onready var anim: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

var robotworking_sound

func _ready() -> void:
#	Sound.play("Robot", self)
	robotworking_sound = Sound.instance("RobotWorking").attach(self)
	pass

func start_working() -> void:
	anim.travel("robotWorking")
	robotworking_sound.start()
	

func stop_working() -> void:
	anim.travel("robotDeactivate")
	robotworking_sound.stop()

# Sound.instance("Robot").attach(self).start()
# Every instance of the Robot event triggers one of the three drill sounds
