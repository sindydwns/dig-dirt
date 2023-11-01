extends Node2D

func _enter_tree():
	Engine.max_fps = 60

func _ready():
	get_node("map").connect("broken_ore", get_node("player").broken_ore)
	get_node("player").connect("on_changed_ore_cnt", get_node("hud").set_ore_cnt)
	get_node("player").connect("on_changed_player_stat", get_node("hud").set_player_stat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
