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
