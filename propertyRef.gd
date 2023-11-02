class_name PropertyRef
extends Node

var property_paths = {}
'''property_paths
{
	"player/Ores/Iron": Node,
	"player/Ores/Iron": Node,
	"player/Ores/Iron": Node,
}
'''
var reserved = {}
'''reserved
{
	nodeId: {
		"player/Ores/Iron": { "node": Node, "callable": callable },
		"player/Ores/Iron": { "node": Node, "callable": callable },
		"player/Ores/Iron": { "node": Node, "callable": callable },
	},
}
'''
var reserved_paths = {}
'''reserved_paths
{
	"player/Ores/Iron": {
		NodeId: callable,
		NodeId: callable,
		NodeId: callable,
	},
}
'''

func subscribe(node: Node, path: String, callable: Callable):
	_remove_reserved(node, path)
	_add_reserved(node, path, callable)

func _remove_reserved_all(node: Node):
	if node == null:
		return
	var id = node.get_instance_id()
	if not reserved.has(id):
		return
	for key in reserved[id].keys():
		_remove_reserved(node, key)

func _remove_reserved(node: Node, path: String):
	if node == null or path.is_empty():
		return
	var id = node.get_instance_id()
	if not reserved.has(id):
		return
	if not reserved[id].has(path):
		return
	if property_paths.has(path):
		property_paths[path].changed.disconnect(reserved[id][path]["callable"])
	reserved[id].erase(path)
	if reserved[id].size() == 0:
		reserved.erase(id)
	reserved_paths[path].erase(id)
	if reserved_paths[path].size() == 0:
		reserved_paths.erase(path)

func _add_reserved(node: Node, path: String, callable: Callable):
	if node == null or path.is_empty():
		return
	var id = node.get_instance_id()
	if not reserved.has(id):
		reserved[id] = {}
	reserved[id][path] = {
		"node": node,
		"callable": callable,
	}
	if not reserved_paths.has(path):
		reserved_paths[path] = {}
	reserved_paths[path][id] = callable
	if property_paths.has(path):
		property_paths[path].connect("changed", callable)

func provide(node: Node):
	if node is Property:
		_provide([], node)
		return
	for child in node.get_children():
		if not child is Property:
			continue
		_provide([], child)

func _provide(pathArr: Array, node: Node):
	if not node is Property:
		return
	var property: Property = node
	pathArr.push_back(property.name)
	
	if property.is_leaf:
		var path = "/".join(pathArr)
		_remove_property(path)
		_add_property(path, property)
	else:
		for child in node.get_children():
			_provide(pathArr, child)
	pathArr.pop_back()

func _add_property(path: String, property: Property):
	if path.is_empty():
		return
	property_paths[path] = property
	if reserved_paths.has(path):
		for key in reserved_paths[path].keys():
			var callable = reserved_paths[path][key]
			property.connect("changed", callable)

func _remove_property(path: String):
	if path.is_empty() or not property_paths.has(path):
		return
	property_paths[path]
	if reserved_paths.has(path):
		for key in reserved_paths[path].keys():
			var callable = reserved_paths[path][key]
			property_paths[path].changed.disconnect(callable)
	property_paths.erase(path)
