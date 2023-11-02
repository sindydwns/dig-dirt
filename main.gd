extends Node2D

func _enter_tree():
	Engine.max_fps = 60

func _ready():
	get_node("map").connect("broken_ore", get_node("player").broken_ore)
	get_node("hud").use(get_node("player"))
