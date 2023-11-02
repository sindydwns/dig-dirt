class_name Subject
extends Node

signal changed(value)
var value:
	get:
		return value
	set(new_value):
		value = new_value
		changed.emit(value)

var use = false

func emit(value):
	changed.emit(value)

func at(path) -> Node:
	return get_node(path)

func _init(name:String, value, is_tree: bool):
	if is_tree and value is Dictionary:
		for key in value:
			append(str(key), value[key], true)
	else:
		self.value = value
		use = true
	self.name = name

func append(name: String, value, is_tree: bool = false) -> Subject:
	if has_node(name):
		print_debug("property: duplicated node name <", name, ">")
	add_child(Subject.new(name, value, is_tree))
	return self

func append_tree(name: String, value) -> Subject:
	append(name, value, true)
	return self

static func create(name:String, value) -> Subject:
	return Subject.new(name, value, false)

static func create_tree(name: String) -> Subject:
	return Subject.new(name, {}, true)
