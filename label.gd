extends Panel

@export var path: String

func find_ref(node: Node) -> PropertyRef:
	while node:
		if node is PropertyRef:
			return node
		node = node.get_parent()
	return null

func _ready():
	var ref = find_ref(self)
	if ref == null:
		print_debug("label: <", name, "> ref is null")
		return
	ref.subscribe(self, path, update_value, PropertyRef.Option.WITH_FIRST_VALUE)

func update_value(value):
	var value_label: Label = get_node("value")
	value_label.text = str(value)
