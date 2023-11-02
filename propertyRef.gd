class_name PropertyRef
extends Node

var properties = {}
'''
{
	player: {
		Ores: {
			Iron: 0
			Silver: 0
			Gold: 0
		},
		Stamina: 0,
		StaminaMax: 0,
	}
}
'''
var reserved = {}
'''
{
	"player/Ores/Iron": [
		{ node: node, callable: Callable }
		{ node: node, callable: Callable }
		{ node: node, callable: Callable }
	]
}
'''

func subscribe(node: Node, path: String, callable: Callable):
	if not reserved.has(path):
		reserved[path] = []
	reserved[path].push_back({
		"node": node,
		"callable": callable,
	})

func _unsubscribe_all_from(list: Array, node: Node):
	range(list.size())
	for i in range(list.size() - 1, -1, -1):
		if list[i]["node"] == node:
			list.remove_at(i)

func provide(node: Node):
	if node is Property:
		_provide(node)
		return
	for child in node.get_children():
		if not child is Property:
			continue
		_provide(child)

func _provide(property: Property):
	if properties.has(property.name):
		print_debug(self.name, " has property:", property.name, " already")
	properties[property.name] = property
	var subscribe_target_keys = reserved.keys().filter(func(x: String): return x.split("/")[0] == property.name)
	for key in subscribe_target_keys:
		for item in reserved[key]:
			var trim_key = _trim_first_path_section(key)
			property.get_node(trim_key).connect("changed", item["callable"])

func _trim_first_path_section(path: String) -> String:
	if path.is_empty():
		return "."
	var splited = path.split("/")
	splited.remove_at(0)
	if splited.size() == 0:
		return "."
	return "/".join(splited)
