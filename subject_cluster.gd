class_name SubjectCluster
extends Node

var subject_paths = {}
'''subject_paths
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

enum Option {
	None = 0,
	WITH_FIRST_VALUE = 1,
}

func subscribe(node: Node, path: String, callable: Callable, option: Option = Option.None):
	_remove_reserved(node, path)
	_add_reserved(node, path, callable, option)

func _add_reserved(node: Node, path: String, callable: Callable, option: Option = Option.None):
	if node == null or path.is_empty():
		return
	var id = node.get_instance_id()
	if not reserved.has(id):
		reserved[id] = {}
		node.tree_exiting.connect(_remove_reserved_all.bind(node))
	reserved[id][path] = {
		"node": node,
		"callable": callable,
		"option": option,
	}
	if not reserved_paths.has(path):
		reserved_paths[path] = {}
	reserved_paths[path][id] = callable
	if subject_paths.has(path):
		var subject: Subject = subject_paths[path]
		subject.changed.connect(callable)
		if option | Option.WITH_FIRST_VALUE:
			callable.call(subject.value)

func _remove_reserved_all(node: Node):
	print(node)
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
	if subject_paths.has(path):
		subject_paths[path].changed.disconnect(reserved[id][path]["callable"])
	reserved[id].erase(path)
	if reserved[id].size() == 0:
		reserved.erase(id)
		node.tree_exiting.disconnect(_remove_reserved_all.bind(node))
	reserved_paths[path].erase(id)
	if reserved_paths[path].size() == 0:
		reserved_paths.erase(path)

func use(node: SubjectCluster):
	if node == null or not node is SubjectCluster:
		return
	for child in node.get_children():
		if not child is Subject:
			continue
		_use([], child)

func _use(pathArr: Array, node: Node):
	if not node is Subject:
		return
	var subject: Subject = node
	pathArr.push_back(subject.name)
	if subject.use_value:
		var path = "/".join(pathArr)
		_remove_subject(path)
		_add_subject(path, subject)
	for child in node.get_children():
		_use(pathArr, child)
	pathArr.pop_back()

func _add_subject(path: String, subject: Subject):
	if path.is_empty() or subject == null:
		return
	subject_paths[path] = subject
	subject.tree_exiting.connect(_remove_subject.bind(path))
	if reserved_paths.has(path):
		for key in reserved_paths[path].keys():
			var callable = reserved_paths[path][key]
			subject.changed.connect(callable)
			if reserved[key][path]["option"] | Option.WITH_FIRST_VALUE:
				callable.call(subject.value)

func _remove_subject(path: String):
	if path.is_empty() or not subject_paths.has(path):
		return
	var subject: Subject = subject_paths[path]
	subject.tree_exiting.disconnect(_remove_subject.bind(path))
	if reserved_paths.has(path):
		for key in reserved_paths[path].keys():
			var callable = reserved_paths[path][key]
			subject.changed.disconnect(callable)
	subject_paths.erase(path)

func at(path) -> Subject:
	return get_node(path)

func append(name: String, value, is_tree: bool = false) -> SubjectCluster:
	if has_node(name):
		print_debug("property: duplicated node name <", name, ">")
	add_child(Subject.new(name, value, is_tree))
	return self

func append_tree(name: String, value) -> SubjectCluster:
	append(name, value, true)
	return self

static func create(name:String, value) -> Subject:
	return Subject.new(name, value, false)

static func create_tree(name: String) -> Subject:
	return Subject.new(name, {}, true)
