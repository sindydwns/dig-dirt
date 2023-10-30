extends Node2D

const Enums = preload("res://Enums.gd")

var ores = {}

signal on_changed_ore_cnt(ores: Enums.Ores, cnt: int)

func _enter_tree():
	Engine.max_fps = 60

func _ready():
	for ore in Enums.Ores.values():
		ores[ore] = 0
		emit_signal("on_changed_ore_cnt", ore, 0)
	get_node("map").connect("broken_ore", _broken_ore)
	
func _broken_ore(global_pos: Vector2, ore: Enums.Ores):
	ores[ore] += 1
	emit_signal("on_changed_ore_cnt", ore, ores[ore])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
