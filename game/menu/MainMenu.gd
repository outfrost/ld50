# Copyright 2021 Outfrost
# This work is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the LICENSE file for more details.

extends Control

signal start_game()

onready var play_button: Button = find_node("PlayButton")
onready var credits_button: Button = find_node("CreditsButton")
onready var quit_button: Button = find_node("QuitButton")
onready var credits_popup: Popup = $CreditsPopup

func _ready() -> void:
	play_button.connect("pressed", self, "on_play_pressed")
	credits_button.connect("pressed", self, "on_credits_pressed")
	quit_button.connect("pressed", self, "on_quit_pressed")
	Sound.instance("Menu Music").reverb(0, 0.5).param("Dampness", 0.2).attach(self).start()
		# This is a random, unrelated track of mine to serve as a test dummy

func on_play_pressed() -> void:
	emit_signal("start_game")


func on_credits_pressed() -> void:
	credits_popup.show()
	Fmod.pause_all_events(true)

func on_quit_pressed() -> void:
	get_tree().quit()
