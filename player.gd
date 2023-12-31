extends CharacterBody2D

const Enums = preload("res://Enums.gd")

const SPEED = 50.0
const TILE_SIZE = 16

@onready var _data: SubjectCluster = get_node("%_data")

func _ready():
	var ores = {}
	for ore in Enums.Ores.keys():
		ores[ore] = 0
	var test = get_node("_data")
	_data.append_tree("ores", ores)
	_data.append("stamina", 100)
	_data.append("staminaMax", 100)
	_data.subscribe(self, "mine", broken_ore)

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	velocity = velocity.lerp(direction * SPEED, delta * 10)
	
	var fixed_direction = Vector2.ZERO
	if direction.x == 0:
		var adjust = (TILE_SIZE / 2) * (-1 if global_position.x < 0 else 1)
		var x = ((int)(global_position.x) / TILE_SIZE) * TILE_SIZE + adjust
		var fixed_x = (x - global_position.x)
		fixed_direction.x = fixed_x
	if direction.y == 0:
		var adjust = (TILE_SIZE / 2) * (-1 if global_position.y < 0 else 1)
		var y = ((int)(global_position.y) / TILE_SIZE) * TILE_SIZE + adjust
		var fixed_y = (y - global_position.y)
		fixed_direction.y = fixed_y
	fixed_direction = fixed_direction.normalized()
	velocity = velocity.lerp(velocity + fixed_direction, delta * 10)
	
	move_and_slide()
	if direction.length() > 0:
		move_and_slide_dig_action(direction, delta)

func broken_ore(event):
	if event == null:
		return
	var oreName = Enums.Ores.find_key(event["type"]);
	_data.at("ores/" + oreName).value += 1

func move_and_slide_dig_action(direction: Vector2, power):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if not collider.has_method("damage_to_wall"):
			continue
		var collision_direction = (collision.get_position() - global_position).normalized()
		if direction.dot(collision_direction) < 0.7:
			continue
		var wall_position = collision_direction + collision.get_position()
		collider.damage_to_wall(wall_position, power)
		_data.at("stamina").value -= 0.1
		return
