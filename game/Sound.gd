extends Node
# Sound system interface
# Helps simplify interactions with fmod-gdnative
#
# Example usage:
# ```
# Sound.instance("Fart").reverb(0, 0.5).param("Dampness", 0.2).attach(self).start()
# ```

class EvInstance:
	# Represents an instance of a sound event

	var id: int

	func _init(id: int) -> void:
		self.id = id

	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			Fmod.release_event(self.id)

	func attach(emitter: Node) -> EvInstance:
		Fmod.attach_instance_to_node(self.id, emitter)
		return self

	func detach() -> EvInstance:
		Fmod.detach_instance_from_node(self.id)
		return self

	func start() -> EvInstance:
		Fmod.start_event(self.id)
		return self

	func stop() -> EvInstance:
		Fmod.stop_event(self.id, Fmod.FMOD_STUDIO_STOP_ALLOWFADEOUT)
		return self

	func stop_immediate() -> EvInstance:
		Fmod.stop_event(self.id, Fmod.FMOD_STUDIO_STOP_IMMEDIATE)
		return self

	func pause() -> EvInstance:
		Fmod.set_event_paused(self.id, true)
		return self

	func resume() -> EvInstance:
		Fmod.set_event_paused(self.id, false)
		return self

	func volume(v: float) -> EvInstance:
		Fmod.set_event_volume(self.id, v)
		return self

	func pitch(p: float) -> EvInstance:
		Fmod.set_event_pitch(self.id, p)
		return self

	func reverb(reverb_instance_index: int, level: float) -> EvInstance:
		Fmod.set_event_reverb_level(self.id, reverb_instance_index, level)
		return self

	func param(param_name: String, v: float) -> EvInstance:
		Fmod.set_event_parameter_by_name(self.id, param_name, v)
		return self

func _ready() -> void:
	Fmod.set_software_format(0, Fmod.FMOD_SPEAKERMODE_STEREO, 0)
	Fmod.init(1024, Fmod.FMOD_STUDIO_INIT_LIVEUPDATE, Fmod.FMOD_INIT_NORMAL)
	Fmod.set_sound_3D_settings(1.0, 8.0, 1.0)

	Fmod.load_bank("res://sound/Master.strings.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	Fmod.load_bank("res://sound/Master.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	#Fmod.load_bank("res://sound/Bank3D.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	#Fmod.load_bank("res://sound/Bank2D.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	Fmod.wait_for_all_loads()

	# Main bus volume
	Fmod.set_bus_volume("bus:/", 0.5)

func set_listener(listener: Node) -> void:
	Fmod.remove_listener(0)
	Fmod.add_listener(0, listener)

func instance(event_name: String) -> EvInstance:
	return EvInstance.new(Fmod.create_event_instance("event:/" + event_name))

func play(event_name: String, emitter: Node = null) -> void:
	Fmod.play_one_shot_attached("event:/" + event_name, emitter)

func play_file(path: String) -> void:
	Fmod.load_file_as_sound(path)
	var id: int = Fmod.create_sound_instance(path)
	Fmod.play_sound(id)

func pause_all() -> void:
	Fmod.pause_all_events(true)

func resume_all() -> void:
	Fmod.pause_all_events(false)

func mute(bus_name: String = "") -> void:
	Fmod.set_bus_mute("bus:/" + bus_name, true)

func unmute(bus_name: String = "") -> void:
	Fmod.set_bus_mute("bus:/" + bus_name, false)

func set_volume(v: float, bus_name: String = "") -> void:
	Fmod.set_bus_volume("bus:/" + bus_name, v)

func pause_bus(bus_name: String) -> void:
	Fmod.set_bus_paused("bus:/" + bus_name, true)

func unpause_bus(bus_name: String) -> void:
	Fmod.set_bus_paused("bus:/" + bus_name, false)
