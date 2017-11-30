extends Node2D
export var current_value = 1
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func roll():
	update_value(int(rand_range(1,7)))

func update_value(val):
	current_value = val
	get_node("Label").set_text(String(current_value))

func _ready():
	update_value(current_value)
