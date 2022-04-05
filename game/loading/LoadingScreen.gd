extends TransitionScreen

signal loading_done()

enum LoadingState {
	INIT,
	LOADING,
	WAITING,
	PROCESSING,
	FINISHED
}

export(Array, PackedScene) var items_to_load = []

onready var loading_spot: Spatial = $Camera/LoadingSpot

var loading_state = LoadingState.INIT

func _ready() -> void:
	fade_in()
	yield(self, "animation_finished")
	loading_state = LoadingState.LOADING

func _process(delta: float) -> void:
	match loading_state:
		LoadingState.INIT:
			return
		LoadingState.LOADING:
			for item in items_to_load:
				var instance = item.instance()
				instance.set_process(false)
				instance.set_physics_process(false)
				loading_spot.add_child(instance)
			loading_state = LoadingState.WAITING
			return
		LoadingState.WAITING:
			loading_state = LoadingState.PROCESSING
			return
		LoadingState.PROCESSING:
			loading_spot.translate(Vector3.BACK * 150.0)
			$Camera.current = false
			$Camera.queue_free()
			loading_state = LoadingState.FINISHED
			continue_startup()
			return
		LoadingState.FINISHED:
			return

func continue_startup() -> void:
	yield(get_tree().create_timer(1.0), "timeout")
#	$Content/LudumDare.hide()
#	$Content/FMOD.hide()
	$Content/Godot.show()
	Sound.play_file("res://sound/gohh.wav", 0.5)
	yield(get_tree().create_timer(2.0), "timeout")
	emit_signal("loading_done")
	fade_out()
