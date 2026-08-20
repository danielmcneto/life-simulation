extends Area2D

@export var fruit_amount: int = 3
@export var reload_time: float = 2.5
var reload_timer: float = 0.0

@onready var fruit1 = $fruit1
@onready var fruit2 = $fruit2
@onready var fruit3 = $fruit3

func _process(delta: float) -> void:
	if fruit_amount == 3:
		fruit1.show()
		fruit2.show()
		fruit3.show()
	elif fruit_amount == 2:
		fruit1.show()
		fruit2.show()
		fruit3.hide()
	elif fruit_amount == 1:
		fruit1.show()
		fruit2.hide()
		fruit3.hide()
	else:
		fruit1.hide()
		fruit2.hide()
		fruit3.hide()
		
	if fruit_amount < 3:
		reload_timer += delta
		if reload_timer >= reload_time:
			fruit_amount += 1
			reload_timer = 0.0
	else:
		reload_timer = 0.0

func can_eat() -> bool:
	return fruit_amount > 0

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("eat") and fruit_amount > 0:
		if body.hunger <= (body.max_hunger * 0.5):
			body.eat()
			eat_me()

func eat_me() -> void:
	fruit_amount -= 1
	reload_timer = 0.0
