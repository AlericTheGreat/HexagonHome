extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var current_player = "blue"
var points_red = 0
var points_blue = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialize Player Positions on the board
	get_node("EndTurn").set_modulate(Color(0,0,1,1))
	set_process_input(true)
	get_node("StreamPlayer").play(0)
	roll_dice()
	
func add_point(player):
	if(player.to_lower() == "red"):
		points_red+=1
	else:
		points_blue+=1


func get_board_pos(world_pos):
	return get_node("TileMap").world_to_map(world_pos)-Vector2(1,0)

func get_world_pos(map_cell):
	return get_node("TileMap").map_to_world(map_cell)+Vector2(32,24)

func get_cell_value(cell):
	return get_node("TileMap").get_cellv(cell)

func check_for_player(cell):
	for node in get_tree().get_nodes_in_group("player"):
		if(node.get_current_pos() == cell or node.get_pos_on_board() == cell):
			return node
	return false

func compare_players(p1,p2):
	return p1.piece_value < p2.piece_value
	
signal timeout

func end_turn():
	var group_nodes = get_tree().get_nodes_in_group(self.current_player)
	group_nodes.sort_custom(self,"compare_players")
	for node in group_nodes:
		node.move_on_board()
	for node in group_nodes:
		if(node.failed_bump):
			node.move_on_board()

	#Swap players
	if(current_player=="blue"):		
		get_node("EndTurn").set_modulate(Color(1,0,0,1))
		current_player="red"
	else:
		get_node("EndTurn").set_modulate(Color(0,0,1,1))
		current_player="blue"
	

func _input(ev):
	#if (ev.type==InputEvent.MOUSE_MOTION ):
#		var cell = get_board_pos(ev.global_pos) #get_node("TileMap").world_to_map(Vector2(ev.global_x,ev.global_y))-Vector2(1,0)#
		#get_node("selection").set_pos(get_world_pos(cell))
		
#	elif(ev.type==InputEvent.MOUSE_BUTTON):
#		var cell = get_board_pos(ev.global_pos) #get_node("TileMap").world_to_map(Vector2(ev.global_x,ev.global_y))-Vector2(1,0)
	pass		
		
func roll_dice():
	randomize()
	get_node("Dice1").roll()
	get_node("Dice2").roll()
	get_node("Dice3").roll()
	#Add Points to the players
	var values = [get_node("Dice1").current_value,get_node("Dice2").current_value,get_node("Dice3").current_value]
	for v in values:
		for node in get_tree().get_nodes_in_group(current_player):
			if(int(node.LabelText)==v):
				node.add_move_points(1)


func _on_TextureButton_pressed():
	roll_dice()

func _on_EndTurn_pressed():
	self.end_turn()
	self.roll_dice()
