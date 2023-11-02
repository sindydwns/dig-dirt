extends ProgressBar

@export var path: String
@export var max_path: String

func link(property: Subject):
	value = property[path].value
	max_value = property[max_path].value
	property[path].connect("changed", func(value): self.value = value)
	property[max_path].connect("changed", func(value): self.max_value = value)

func _ready():
	var ref = get_node("%_data")
	if ref == null:
		print_debug("label: <", name, "> ref is null")
		return
	ref.subscribe(self, path, func(value): self.value = value, SubjectCluster.Option.WITH_FIRST_VALUE)
	ref.subscribe(self, max_path, func(value): self.max_value = value, SubjectCluster.Option.WITH_FIRST_VALUE)
