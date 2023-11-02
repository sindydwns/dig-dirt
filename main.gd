extends Node2D

func _enter_tree():
	Engine.max_fps = 60

func _ready():
	get_node("player/_data").use(get_node("map/_data"))
	get_node("hud/_data").use(get_node("player/_data"))
