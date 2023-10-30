extends Panel

const Enums = preload("res://Enums.gd")

@export var key : Enums.Ores

func find_parent_with_signal(node, signal_name):
	while node:
		if node.has_signal(signal_name):
			return node
		node = node.get_parent()
	return null

func _ready():
	var node: Node = find_parent_with_signal(self, "on_changed_ore_cnt")
	if node == null:
		return
	node.connect("on_changed_ore_cnt", update_value)

func update_value(ore_type: Enums.Ores, value: int):
	if ore_type == key:
		var value_label: Label = get_node("value")
		value_label.text = str(value)
