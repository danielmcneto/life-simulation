extends Node2D

@export var ui_text: RichTextLabel 

var ze_scene = preload("res://prefabs/ze.tscn")

func _ready() -> void:
	spawn_zezzits(10);

func _process(delta: float) -> void:
	var all_zes = get_tree().get_nodes_in_group("zezzits")
	var total_zes = all_zes.size()
	
	if total_zes == 0:
		if ui_text:
			ui_text.text = "Species extinct!"
		return
		
	var sum_speed: float = 0.0
	var sum_sight: float = 0.0
	
	for ze in all_zes:
		if is_instance_valid(ze):
			sum_speed += ze.speed
			sum_sight += ze.sight_range
			
	var avg_speed = sum_speed / total_zes
	var avg_sight = sum_sight / total_zes
	
	if ui_text:
		ui_text.text = "Alive Zezzits: %d\nAverage speed: %.1f\nAverage vision: %.1f" % [total_zes, avg_speed, avg_sight]
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_game"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("1"):
		spawn_zezzits(10)
	if event.is_action_pressed("2"):
		spawn_zezzits(20)
	if event.is_action_pressed("3"):
		spawn_zezzits(30)
	if event.is_action_pressed("4"):
		spawn_zezzits(40)
	if event.is_action_pressed("5"):
		spawn_zezzits(50)

func spawn_zezzits(number: int) -> void:
	var all_zes = get_tree().get_nodes_in_group("zezzits")
	for ze in all_zes:
		ze.queue_free()

	for i in range(number):
		var baby = ze_scene.instantiate()
		add_child(baby)
		var baby_script = baby.get_node("CharacterBody2D")
		baby_script.speed = 200
		baby_script.sight_range = 500
		baby.global_position = Vector2(randf_range(-1100, 1100), randf_range(-800, 800))
