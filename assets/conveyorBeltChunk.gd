extends Spatial

onready var anim: AnimationPlayer = $AnimationPlayer

func roll(speed: float) -> void:
	anim.play("conveyorBeltAnim", - 1.0, speed)

func stop() -> void:
	anim.stop(false)
