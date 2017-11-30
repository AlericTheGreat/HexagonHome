extends Node2D
export var LabelText = "1"
export var PlayerColor = "blue"
export var Direction = 0
var previous_dir = 0
var BlueSprite = load("res://Assest/Images/player_blue.png")
var RedSprite = load("res://Assest/Images/player_red.png")
var rotations = [45,90,135,225,270,315,360]
var movements = [Vector2(-64,-24),Vector2(-32,0),
				Vector2(-32,24),Vector2(32,24),
				Vector2(32,0),Vector2(32,-24)]
var current_pos = Vector2(0,0)
var move_points = 0
var piece_value = int(LabelText)

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if(PlayerColor.to_lower() == "red"):
		get_node("Sprite").set_texture(RedSprite)
	else:
		get_node("Sprite").set_texture(BlueSprite)
	get_node("Label").set_text(LabelText)
	get_node("Sprite").set_rot( deg2rad(rotations[Direction]))
	set_process_input(true)
	piece_value = int(LabelText)
	
func clear_move_points():
	self.move_points = 0
	get_node("Sprite/MovePoint1").hide()
	get_node("Sprite/MovePoint2").hide()
	get_node("Sprite/MovePoint3").hide()

func add_move_points(pts):
	self.move_points+=pts
	if(self.move_points > 3):
		self.move_points = 3
	elif(self.move_points < 0):
		self.move_points = 0
	
	get_node("Sprite/MovePoint1").hide()
	get_node("Sprite/MovePoint2").hide()
	get_node("Sprite/MovePoint3").hide()

	if(self.move_points >= 1):
		get_node("Sprite/MovePoint1").show()
	if(self.move_points >= 2):
		get_node("Sprite/MovePoint2").show()
	if(self.move_points >= 3):
		get_node("Sprite/MovePoint3").show()
		
		
func _on_rotation_arrow_pressed():
	if(get_parent().current_player.to_lower() == self.PlayerColor.to_lower()):
		if(move_points>0):
			add_move_points(-1)
			self.current_pos = get_parent().get_board_pos(self.get_global_pos())+Vector2(1,0)
			self.Direction+=1
			if(self.Direction >= 6):
				self.Direction=0
			get_node("Sprite").set_rot( deg2rad(rotations[Direction]))
	


func _on_rotation_arrow2_pressed():
	if(get_parent().current_player.to_lower() == self.PlayerColor.to_lower()):
		if(move_points>0):
			add_move_points(-1)
			self.current_pos = get_parent().get_board_pos(self.get_global_pos())+Vector2(1,0)
			self.Direction-=1
			if(self.Direction < 0):
				self.Direction=5
			get_node("Sprite").set_rot( deg2rad(rotations[Direction]))

func rotate_to_dir(dir):
	if(get_parent()):
		self.current_pos = get_parent().get_board_pos(self.get_global_pos())+Vector2(1,0)
		self.previous_dir=self.Direction
		self.Direction=dir
		get_node("Sprite").set_rot( deg2rad(rotations[Direction]))

func set_pos_on_board(pos):
	self.current_pos=pos
	
func get_current_pos():
	return self.current_pos
	
func get_pos_on_board():
	self.current_pos = get_parent().get_board_pos(self.get_global_pos())+Vector2(1,0)
	return self.current_pos

var move_speed = 100
var current_movement_position = 0
var move_waiting = false
var bumper = null
var failed_bump = false

func _fixed_process(delta):
	get_node("Path2D/PathFollow2D").set_offset(get_node("Path2D/PathFollow2D").get_offset() + delta * move_speed)
	if(get_node("Path2D/PathFollow2D").get_unit_offset() > 1):
		set_fixed_process(false)
		if(self.bumper):
			print("Moving bumper:"+String(self.bumper.piece_value))
			self.bumper.move_on_board()
			self.bumper = null
		if(self.move_waiting):
			self.move_on_board()
			self.move_waiting=false
		return
	var next_pos = get_node("Path2D/PathFollow2D").get_pos()
	self.set_pos(next_pos)
	
func animate_move(start,end):
	var curve = Curve2D.new()
	curve.add_point(start)
	curve.add_point(end)
	get_node("Path2D").set_curve(curve)
	get_node("Path2D/PathFollow2D").set_offset(0.0)
	set_fixed_process(true)

func move_on_board():
	self.failed_bump=false
	print(String(self.piece_value )+" is moving")
	if(is_fixed_processing()):
		move_waiting=true
		print(String(self.piece_value )+" is waiting to move")
		return
	self.current_pos = get_parent().get_board_pos(self.get_global_pos())+Vector2(1,0)
	var projected = get_parent().get_board_pos(get_node("Sprite/DiceDot").get_global_pos())+Vector2(1,0)
	var projected_value = get_parent().get_cell_value(projected)
	#Handle Home
	if(projected_value==2 or projected_value==1):
		var projected_color = "Blue"
		if(projected_value==2):
			projected_color="Red"
		#get_parent().add_point(projected_color.to_lower())
		get_parent().get_node(projected_color+"Home").add_resident(self)
		self.remove_from_group("player")
		clear_move_points()
		#get_parent().remove_child(self)
		return true
	#Handle All Other Cases
	if(projected_value != -1):
		var bumped = get_parent().check_for_player(projected)
		if(!bumped):
			self.current_pos= projected
			var start=self.get_global_pos()
			var end=get_parent().get_world_pos(projected)
			self.animate_move(start,end)
			return true
		else:
			if(bumped.bump(self.Direction, self)):
				move_on_board()
				print("Bumped "+String(bumped.piece_value) + " by " + String(self.piece_value))
				return true
			bumped.bumper=self
			self.failed_bump=true
			print("Failed Bump")
			return false

func bump(dir, bumper):
	#rotate to dir
	rotate_to_dir(dir)
	self.bumper=bumper
	#move
	var success = move_on_board()
	#rotate to original
	rotate_to_dir(self.previous_dir)
	return success
	
func _on_button_move_pressed():
	if(get_parent().current_player.to_lower() == self.PlayerColor.to_lower()):
		if(move_points>0):
			if(move_on_board()):
				add_move_points(-1)
