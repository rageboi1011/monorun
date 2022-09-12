extends Node2D

export var mood_color_override = Color(0,0,0)

func _ready():
	GlobalVars.mood_color = mood_color_override
	var players = get_tree().get_nodes_in_group("Player")
	print(players)
	for player in players:
		var PLAYER_CONT = Node2D.new()
		var TRAIL_CONT = Node2D.new()
		player.emit_signal("trail_cont", TRAIL_CONT)
		PLAYER_CONT.add_child(TRAIL_CONT)
		PLAYER_CONT.material = player.material
		TRAIL_CONT.use_parent_material = true
		add_child_below_node($Label, PLAYER_CONT)
	
	WsClient.connect_to_url("wss://MonorunSignalingServer.donovanedwards.repl.co")
	WsClient.connect("ws_connect", self, "_ws_connected")
	WsClient.connect("new_data", self, "_ws_data")

func _ws_connected():
	add_line("CONNECTED!")

func _ws_data(msg):
	add_line(msg)

func _process(delta):
	material.set_shader_param("MOOD_COLOR", GlobalVars.mood_color)
	$Background.color = GlobalVars.mood_color
	if (GlobalVars.current_camera != null):
		$Background.rect_position = GlobalVars.current_camera.get_camera_screen_center() - Vector2(1280,720)/2
	
	$Crosshair.position = get_global_mouse_position()

func add_line(text):
	var lines = $Label.get_line_count()
	if (lines == 11):
		var textArr = $Label.text.split("\n")
		textArr.remove(0)
		$Label.text = textArr.join("\n")
	if ($Label.text == ""):
		$Label.text += text
	else:
		$Label.text += "\n"+text
