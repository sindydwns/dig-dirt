extends ProgressBar

@export var path: String
@export var max_path: String

func link(property: Property):
	value = property[path].value
	max_value = property[max_path].value
	property[path].connect("changed", func(value): self.value = value)
	property[max_path].connect("changed", func(value): self.max_value = value)


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
	ref.subscribe(self, path, func(value): self.value = value, PropertyRef.Option.WITH_FIRST_VALUE)
	ref.subscribe(self, max_path, func(value): self.max_value = value, PropertyRef.Option.WITH_FIRST_VALUE)
