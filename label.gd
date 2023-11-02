extends Panel

@export var path: String

func _ready():
	var ref = get_node("%_data")
	if ref == null:
		print_debug("label: <", name, "> ref is null")
		return
	ref.subscribe(self, path, update_value, SubjectCluster.Option.WITH_FIRST_VALUE)

func update_value(value):
	var value_label: Label = get_node("value")
	value_label.text = str(value)
