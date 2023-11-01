class_name Property
extends Node

signal changed(value)
var value:
	get:
		return value
	set(new_value):
		value = new_value
		changed.emit(value)

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

func _get(key):
	return get_node("./" + key)
