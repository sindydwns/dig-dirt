extends ProgressBar

@export var min_path: String
@export var max_path: String

func link(property: Property):
	value = property[min_path].value
	max_value = property[max_path].value
	property[min_path].connect("changed", func(value): self.value = value)
	property[max_path].connect("changed", func(value): self.max_value = value)
