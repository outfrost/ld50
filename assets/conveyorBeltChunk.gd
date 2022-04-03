extends Spatial

onready var anim: AnimationPlayer = $AnimationPlayer

func roll() -> void:
	anim.play("conveyorBeltAnim")

func stop() -> void:
	anim.stop()
