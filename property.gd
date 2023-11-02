class_name Property
extends Node

signal changed(value)
var value:
	get:
		return value
	set(new_value):
		value = new_value
		changed.emit(value)

var is_leaf = false

func emit():
	changed.emit(value)

func init(value):
	if value is Dictionary:
		for key in value:
			var node = Node.new()
			node.name = str(key)
			node.set_script(self.get_script())
			node.init(value[key])
			add_child(node)
	else:
		self.value = value
		is_leaf = true
