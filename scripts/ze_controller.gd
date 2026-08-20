extends CharacterBody2D

var is_busy: bool = false

@export var speed: float = 200.0
@export var min_limit: Vector2 = Vector2(-1050, -550)
@export var max_limit: Vector2 = Vector2(1050, 550)

@export var max_hunger: float = 60
var hunger: float = 60
@export var hunger_lost_rate: float = 1


@export var sight_range: float = 500.0
var target_fruit: Node2D = null

var mating_cooldown: float = 5.0
var gender: int = 0

var direction: Vector2 = Vector2.ZERO
var timer: float = 0.0

var animation_time: float = 0.0

func _ready() -> void:
	gender = randi() % 2
	if modulate == Color(1, 1, 1, 1):
		modulate = Color.from_hsv(randf_range(0.0, 1), 0.8, 0.9)
	change_direction()

func _physics_process(delta: float) -> void:
	if is_busy:
		return
	var metabolic_cost = pow(speed/ 100.0, 1.2) * hunger_lost_rate
	hunger -= metabolic_cost * delta
	if hunger <= 0:
		die()

	if mating_cooldown > 0:
		mating_cooldown -= delta
		
	if hunger <= (max_hunger * 0.5):
		search_food(delta)
	elif hunger >= (max_hunger * 0.8) and mating_cooldown <= 0:
		try_reproduce()
	else:
		timer -= delta
		if timer <= 0:
			change_direction()

	velocity = direction * speed
	move_and_slide()
	
	if velocity.length() > 0:
		animation_time += delta * 15.0
		rotation = sin(animation_time) * 0.2
	else:
		rotation = lerp_angle(rotation, 0.0, 0.1)
		animation_time = 0.0
	
	global_position.x = clamp(global_position.x, min_limit.x, max_limit.x)
	global_position.y = clamp(global_position.y, min_limit.y, max_limit.y)
	
	if global_position.x == min_limit.x or global_position.x == max_limit.x or \
	   global_position.y == min_limit.y or global_position.y == max_limit.y:
		change_direction()

func change_direction() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	timer = randf_range(1.0, 3.0)

func eat() -> void:
	eat_animation()
	hunger = max_hunger
	change_direction()
	stay_still(0.5)

func eat_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 0.7), 0.1)
	tween.tween_property(self, "scale", Vector2(0.8, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.15)

func mating_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation", rotation + TAU, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func death_animation() -> Tween:
	var tween = create_tween()
	tween.tween_property(self, "rotation", rotation + deg_to_rad(90), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	return tween

func search_food(delta: float) -> void:
	if is_instance_valid(target_fruit):
		if target_fruit.has_method("eat_me") and not target_fruit.eat_me():
			target_fruit = null 
	
	if not is_instance_valid(target_fruit):
		target_fruit = find_nearest_fruit()
	
	if is_instance_valid(target_fruit):
		var dist = global_position.distance_to(target_fruit.global_position)
		if dist > 20.0:
			direction = global_position.direction_to(target_fruit.global_position)
			velocity = direction * speed
			var food_area = target_fruit.get_node("Area2D")
			if food_area.fruit_amount <= 0:
				target_fruit = null 
				change_direction()
		else:
			velocity = Vector2.ZERO
			var food_area = target_fruit.get_node("Area2D")
			if food_area.fruit_amount > 0:
				food_area.eat_me() 
				eat()
				target_fruit = null
			else:
				target_fruit = null 
				change_direction()
			
	else:
		timer -= delta
		if timer <= 0:
			change_direction()
		velocity = direction * speed

func find_nearest_fruit() -> Node2D:
	var all_fruits = get_tree().get_nodes_in_group("food")
	var nearest: Node2D = null
	var shortest_distance: float = INF
	
	for fruit in all_fruits:
		if not is_instance_valid(fruit): continue
		
		if fruit.get_node("Area2D").fruit_amount <= 0: continue
			
		var distance = global_position.distance_to(fruit.global_position)
		if distance <= sight_range and distance < shortest_distance:
			shortest_distance = distance
			nearest = fruit
			
	return nearest

func try_reproduce() -> void:
	var all_zezzits = get_tree().get_nodes_in_group("zezzits")
	var nearest_partner: Node2D = null
	
	for other_ze in all_zezzits:
		if other_ze == self:
			continue
		if not is_instance_valid(other_ze):
			continue
			
		if other_ze.hunger >= (other_ze.max_hunger * 0.8) and other_ze.mating_cooldown <= 0:
			var distance = global_position.distance_to(other_ze.global_position)
			
			if distance <= 150:
				nearest_partner = other_ze
				velocity = Vector2.ZERO
				break
			elif distance <= sight_range:
				var partner_direction = global_position.direction_to(other_ze.global_position)
				direction = partner_direction
				return
				
	if is_instance_valid(nearest_partner):
		reproduce_with(nearest_partner)

func reproduce_with(partner: Node2D) -> void:
	mating_cooldown = 8.0
	partner.mating_cooldown = 8.0
	
	hunger -= 50.0
	partner.hunger -= 50.0
	
	var ze_scene = load("res://prefabs/ze.tscn")
	var baby = ze_scene.instantiate()
	
	mating_animation()
	partner.mating_animation()
	partner.stay_still(1.0)
	stay_still(1.0)
	
	get_tree().current_scene.add_child(baby)
	
	var baby_script = baby.get_node("CharacterBody2D")
	baby_script.speed = ((speed + partner.speed) / 2.0) + randf_range(-50.0, 50.0)
	baby_script.sight_range = ((sight_range + partner.sight_range) / 2.0) + randf_range(-30.0, 30.0)
	
	var father_hue = self.modulate.h * TAU
	var mother_hue = partner.modulate.h * TAU
	
	var avg_angle = lerp_angle(father_hue, mother_hue, 0.5)
	var avg_hue = wrapf(avg_angle / TAU, 0.0, 1.0)
	var mutated_hue = fposmod(avg_hue + randf_range(-0.1, 0.1), 1.0)
	
	baby_script.modulate = Color.from_hsv(mutated_hue, 0.8, 0.9)
	
	baby.global_position = (global_position + partner.global_position) / 2 + Vector2(randf_range(-20, 20), randf_range(-20, 20))

func stay_still(time: float) -> void:
	is_busy = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(time).timeout
	is_busy = false

func die() -> void:
	set_physics_process(false)
	await death_animation().finished
	queue_free()
