extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Original_pressed():
	get_tree().change_scene("res://BaseMap.tscn")



func _on_Back_pressed():
	get_tree().change_scene("res://HexagonTitlescreen.tscn")



func _on_Original1_pressed():
	get_tree().change_scene("res://ModMap.tscn")
