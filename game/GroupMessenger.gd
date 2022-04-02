# Copyright 2021 Outfrost
# This work is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the LICENSE file for more details.

class_name GroupMessenger

var message: String
var groups: Array = []
var owner: Node

func _init(owner: Node, message: String, groups: Array = []):
	self.owner = owner
	self.message = message
	self.groups = groups

func add_group(group: String):
	groups.push_back(group)

func remove_group(group: String):
	var i = groups.find(group)
	if i != -1:
		groups.remove(i)

func dispatch(args: Array = []):
	var tree = owner.get_tree()
	for group in groups:
		tree.call_group(group, "on_" + message, args)
