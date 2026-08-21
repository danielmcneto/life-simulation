extends Node

var file_path: String = "user://simulation_data.csv"

var time_passed: float = 0.0
var save_interval: float = 10.0

func _ready() -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("Time_seconds,Zezzits_number,Avarge_vel,Avarge_vision")
		file.close()
		print("File created in: ", ProjectSettings.globalize_path(file_path))
	else:
		print("Error trying to create file!")

func _process(delta: float) -> void:
	time_passed += delta
	
	if time_passed >= save_interval:
		time_passed = 0.0
		save_data()

func save_data() -> void:
	var all_zes = get_tree().get_nodes_in_group("zezzits")
	var total_zes = all_zes.size()
	
	var avarge_speed: float = 0.0
	var avarge_sight: float = 0.0
	
	if total_zes > 0:
		var all_speed: float = 0.0
		var all_sight: float = 0.0
		
		for ze in all_zes:
			if is_instance_valid(ze):
				all_speed += ze.speed
				all_sight += ze.sight_range
				
		avarge_speed = all_speed / total_zes
		avarge_sight = all_sight / total_zes
	
	var time = int(Time.get_ticks_msec() / 1000)
	
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		
		var linha = "%d,%d,%.2f,%.2f" % [time, total_zes, avarge_speed, avarge_sight]
		file.store_line(linha)
		file.close()
		
	else:
		print("Error trying to open the file!")
