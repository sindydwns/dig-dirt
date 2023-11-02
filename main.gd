extends Node2D

func _enter_tree():
	Engine.max_fps = 60

func _ready():
	get_node("map").connect("broken_ore", get_node("player").broken_ore)
	get_node("hud").emit(get_node("player"))

func _print(value):
	print(value)
