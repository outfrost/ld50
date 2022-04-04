extends Control

signal start_game()

onready var play_button: Button = find_node("PlayButton")
onready var credits_button: Button = find_node("CreditsButton")
onready var quit_button: Button = find_node("QuitButton")
onready var credits_popup: Popup = $CreditsPopup

var music_menu

func _ready() -> void:
	play_button.connect("pressed", self, "on_play_pressed")
	credits_button.connect("pressed", self, "on_credits_pressed")
	quit_button.connect("pressed", self, "on_quit_pressed")
	music_menu = Sound.instance("Music Menu").attach(self)

func start() -> void:
	show()
	music_menu.start()
	# This is a singular drill sound, placed to serve as a test dummy
	Sound.instance("Drill").reverb(0, 0.5).param("Dampness", 0.2).attach(self).start()

func on_play_pressed() -> void:
	emit_signal("start_game")
	Sound.play("GUI Play")
	music_menu.stop()

func on_credits_pressed() -> void:
	credits_popup.show()
	Sound.play("Drill GUI 1")
	Sound.play("Button")

func on_quit_pressed() -> void:
	get_tree().quit()
