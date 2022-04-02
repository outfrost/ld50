# Copyright 2021 Outfrost
# This work is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the LICENSE file for more details.

extends Node

onready var label: Label = $DebugLabel

var buffer: String = ""

func _ready():
	label.text = ""

func _process(_delta):
	label.text = buffer
	buffer = ""

func display(s: String):
	buffer += s + "\n"
