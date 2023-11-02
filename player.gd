extends CharacterBody2D

const Enums = preload("res://Enums.gd")

const SPEED = 50.0
const TILE_SIZE = 16

var property: Subject

func _enter_tree():
	var ores = {}
	for ore in Enums.Ores.keys():
		ores[ore] = 0
	property = Subject.create_tree(name)
	property.append_tree("Ores", ores)
	property.append("Stamina", 100)
	property.append("StaminaMax", 100)
	add_child(property)

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

func broken_ore(global_pos: Vector2, ore: Enums.Ores):
	property.get_node("Ores/" + Enums.Ores.find_key(ore)).value += 1

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
		property.get_node("Stamina").value -= 0.1
		return
