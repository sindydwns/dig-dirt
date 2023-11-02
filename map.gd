class_name CustomMap
extends TileMap

const Enums = preload("res://Enums.gd")

const TILE_ATLAS = 2

const BACKGROUND_LAYER = 0
const TILE_LAYER = 1
const ORE_LAYER = 2
const BROKEN_LAYER = 3

const BACKGROUND_TILE = Vector2i(1, 0)
const BROKEN_TILE_00 = Vector2i(5, 0)
const BROKEN_TILE_20 = Vector2i(6, 0)
const BROKEN_TILE_40 = Vector2i(7, 0)
const BROKEN_TILE_60 = Vector2i(8, 0)
const BROKEN_TILE_80 = Vector2i(9, 0)

const ORE_IRON = Vector2i(10, 0)
const ORE_SILVER = Vector2i(11, 0)
const ORE_GOLD = Vector2i(12, 0)

const TERRAIN_TILE_SET = 0
const TERRAIN_TILE_DIRT = 0

var damage = {}

@onready var _data = get_node("%_data")

func _ready():
	_data.append("mine", null)

func damage_to_wall(global_pos: Vector2, value):
	var tile_pos = local_to_map(global_pos)
	var tile = get_cell_tile_data(TILE_LAYER, tile_pos)
	if tile == null:
		return
	var hp = tile.get_custom_data("hp")
	if hp == 0:
		return
	if not damage.has(tile_pos):
		damage[tile_pos] = 0.0
	damage[tile_pos] += value
	if damage[tile_pos] >= hp * 0.8:
		set_cell(BROKEN_LAYER, tile_pos, TILE_ATLAS, BROKEN_TILE_80)
	elif damage[tile_pos] >= hp * 0.6:
		set_cell(BROKEN_LAYER, tile_pos, TILE_ATLAS, BROKEN_TILE_60)
	elif damage[tile_pos] >= hp * 0.4:
		set_cell(BROKEN_LAYER, tile_pos, TILE_ATLAS, BROKEN_TILE_40)
	elif damage[tile_pos] >= hp * 0.2:
		set_cell(BROKEN_LAYER, tile_pos, TILE_ATLAS, BROKEN_TILE_20)
	elif damage[tile_pos] > 0:
		set_cell(BROKEN_LAYER, tile_pos, TILE_ATLAS, BROKEN_TILE_00)
	if damage[tile_pos] >= hp:
		_break_wall(tile_pos)
		return true
	return false

func _get_surrounding_cells(pos : Vector2i):
	var cells = []
	cells.append(pos + Vector2i(0, 0))
	cells.append(pos + Vector2i(1, 0))
	cells.append(pos + Vector2i(-1, 0))
	cells.append(pos + Vector2i(0, 1))
	cells.append(pos + Vector2i(0, -1))
	cells.append(pos + Vector2i(1, 1))
	cells.append(pos + Vector2i(-1, 1))
	cells.append(pos + Vector2i(1, -1))
	cells.append(pos + Vector2i(-1, -1))
	return cells

func _break_wall(tile_pos: Vector2i):
	var tile = get_cell_tile_data(TILE_LAYER, tile_pos)
	if tile == null:
		return
	var ore = get_cell_tile_data(ORE_LAYER, tile_pos)
	if ore != null:
		var ore_type = ore.get_custom_data("ore_type")
		_data.at("mine").emit({
			"type": ore_type,
			"pos": map_to_local(tile_pos),
		});
	damage.erase(tile_pos)
	set_cell(BACKGROUND_LAYER, tile_pos, TILE_ATLAS, BACKGROUND_TILE)
	erase_cell(ORE_LAYER, tile_pos)
	erase_cell(BROKEN_LAYER, tile_pos)
	set_cells_terrain_connect(TILE_LAYER, [tile_pos], TERRAIN_TILE_SET, -1, false)
	var surroundings = _get_surrounding_cells(tile_pos)
	var targets = []
	for surrounding in surroundings:
		var background = get_cell_tile_data(BACKGROUND_LAYER, surrounding)
		if background == null:
			targets.push_back(surrounding)
			var rf = randf()
			if rf < 0.2:
				set_cell(ORE_LAYER, surrounding, TILE_ATLAS, ORE_IRON)
			elif rf < 0.25:
				set_cell(ORE_LAYER, surrounding, TILE_ATLAS, ORE_SILVER)
			elif rf < 0.26:
				set_cell(ORE_LAYER, surrounding, TILE_ATLAS, ORE_GOLD)
			set_cell(BACKGROUND_LAYER, surrounding, TILE_ATLAS, BACKGROUND_TILE)
	set_cells_terrain_connect(TILE_LAYER, targets, TERRAIN_TILE_SET, TERRAIN_TILE_DIRT)
