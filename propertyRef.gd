class_name PropertyRef
extends Node

var property: Property
var reserves = {}

func subscribe(path: String, callable: Callable):
	if property == null:
		reserves
	callable.call()
	pass

func provide(node: Node):
	
	property = node
