extends Node2D
export var LabelText = "1"
export var PlayerColor = "blue"
export var Direction = 0
var previous_dir = 0
var BlueSprite = load("res://Assets/Images/player_blue.png")
var RedSprite = load("res://Assets/Images/player_red.png")
var rotations = [45,90,135,225,270,315,360]
var movements = [Vector2(-64,-24),Vector2(-32,0),
				Vector2(-32,24),Vector2(32,24),
				Vector2(32,0),Vector2(32,-24)]
var current_pos = Vector2(0,0)
var move_points = 3
var piece_value = int(LabelText)
var movement_curve = Curve2D.new()
var move_speed = 100
var current_movement_position = 0
var movement_dir = self.Direction
var movement_positions = []
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
	add_move_points(0)
	self.current_pos = get_parent().get_board_pos(self.get_global_pos())+Vector2(1,0)
	self.set_pos(get_parent().get_world_pos(self.current_pos))
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

func _fixed_process(delta):
	if(self.movement_curve != null and self.movement_curve.get_point_count() >0):
		get_node("Path2D/PathFollow2D").set_offset(get_node("Path2D/PathFollow2D").get_offset() + delta * move_speed)
		if(get_node("Path2D/PathFollow2D").get_unit_offset() > 1):
			set_fixed_process(false)
			self.movement_curve.clear_points()
			self.movement_positions.clear()
			self.current_pos = get_parent().get_board_pos(self.get_global_pos())+Vector2(1,0)
			var bumped = get_bumped(self.current_pos)
			if(bumped.size()>0):
				var projected = get_parent().get_board_pos(get_node("Sprite/DiceDot").get_global_pos())+Vector2(1,0)
				var projected_value = get_parent().get_cell_value(projected)
				if(projected_value!=-1):
					bumped[0].bump(self.movement_dir)
			return
		var next_pos = get_node("Path2D/PathFollow2D").get_pos()
		self.set_pos(next_pos)
	
func animate_move():
	for p in movement_positions:
		self.movement_curve.add_point(p)
	get_node("Path2D").set_curve(self.movement_curve)
	get_node("Path2D/PathFollow2D").set_offset(0.0)
	set_fixed_process(true)

func get_bumped(pos):
	var bumped = get_parent().check_for_player(pos)
	bumped.remove(bumped.find(self))
	return bumped

func check_bump(dir):
	rotate_to_dir(dir)
	var possible = check_move()
	rotate_to_dir(self.previous_dir)
	return possible

func bump(dir):
	rotate_to_dir(dir)
	#rotate_to_dir(dir)
	var success = move_on_board()
	#rotate to original
	rotate_to_dir(self.previous_dir)
	self.animate_move()
	return success

func check_move():
	var projected = get_parent().get_board_pos(get_node("Sprite/DiceDot").get_global_pos())+Vector2(1,0)
	var projected_value = get_parent().get_cell_value(projected)
	if(projected_value != -1):
		var bumped = get_bumped(projected)
		if(bumped.size()==0):
			return true
		else:
			return bumped[0].check_bump(self.Direction)
	return false

func move_on_board():
	self.current_pos = get_parent().get_board_pos(self.get_global_pos())+Vector2(1,0)
	if(check_move()): #You're not moving off the board, and if you're gonna bump things they won't move off either
		self.movement_dir=self.Direction
		var projected = get_parent().get_board_pos(get_node("Sprite/DiceDot").get_global_pos())+Vector2(1,0)
		var projected_value = get_parent().get_cell_value(projected)
		var start = get_parent().get_world_pos(self.current_pos)
		var end = get_parent().get_world_pos(projected)
		if(self.movement_positions.size()==0):
			self.movement_positions = [start,end]
		else:
			self.movement_positions.insert(1,end)
		return true
	return false



func _on_button_move_pressed():
	if(get_parent().current_player.to_lower() == self.PlayerColor.to_lower()):
		if(move_points>0):
			if(move_on_board()):
				self.animate_move()
				add_move_points(-1)
