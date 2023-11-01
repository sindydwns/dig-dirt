extends CanvasLayer

const Enums = preload("res://Enums.gd")

signal on_changed_ore_cnt(type: int, value: int)
signal on_changed_player_stat(type: int, value: float)

func set_ore_cnt(ore: Enums.Ores, cnt: int):
	emit_signal("on_changed_ore_cnt", ore, cnt)

func set_player_stat(stat: Enums.PlayerStat, value: float):
	emit_signal("on_changed_player_stat", stat, value)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
