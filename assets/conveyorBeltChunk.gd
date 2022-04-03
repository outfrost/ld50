extends Spatial

onready var anim: AnimationPlayer = $AnimationPlayer

var belt_sound

func _ready() -> void:
	belt_sound = Sound.instance("Belt").attach(self)

func roll(speed: float) -> void:
	anim.play("conveyorBeltAnim", - 1.0, speed)
	belt_sound.start()


func stop() -> void:
	anim.stop(false)
	belt_sound.stop()

