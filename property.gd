class_name Property
extends Node

signal changed(value)
var value:
	get:
		return value
	set(new_value):
		value = new_value
		changed.emit(value)

var use = false

func emit():
	changed.emit(value)

func _init(name:String, value, is_tree: bool = false):
	if is_tree and value is Dictionary:
		for key in value:
			append(str(key), value[key], true)
	else:
		self.value = value
		use = true
	self.name = name

func append(name:String, value, is_tree: bool = false) -> Property:
	if has_node(name):
		print_debug("property: duplicated node name <", name, ">")
	add_child(Property.new(name, value, is_tree))
	return self
