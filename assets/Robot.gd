extends Spatial

onready var anim: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready() -> void:
	pass

func start_working() -> void:
	anim.travel("robotWorking")

func stop_working() -> void:
	anim.travel("robotDeactivate")

# Sound.instance("Robot").attach(self).start()
# Every instance of the Robot event triggers one of the three drill sounds
