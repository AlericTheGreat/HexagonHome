extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var BlueSprite = load("res://Assets/Images/prisonBlue.png")
var RedSprite = load("res://Assets/Images/prisonRed.png")
export var playerColor = "blue"
var residentCount = 0

func set_color(colorName):
	if(playerColor == "red"):
		get_node("Sprite").set_texture(RedSprite)
	else:
		get_node("Sprite").set_texture(BlueSprite)
	
func add_resident(resident):
	residentCount+=1
	resident.set_pos(get_node("Pos"+String(residentCount)).get_global_pos())

func _ready():
	# Called every time the node is added to the scene.
	set_color(playerColor)
	# Initialization here
	pass
