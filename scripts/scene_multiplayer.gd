extends Node2D

const STATES = {
	0: "input_name",
	1: "choose_lobby"
}

var STATE = 0
var LobbyTemplate = preload("res://objects/LobbyTemplate.tscn")

func _ready():
	WsClient.connect_to_url("wss://MonorunSignalingServer.donovanedwards.repl.co")
	WsClient.connect("ws_connect", self, "_ws_connected")
	WsClient.connect("new_data", self, "_ws_data")
	
	$LobbyList/HostButton.connect("button_up", self, "_host_lobby")

func _ws_connected():
	pass

func _ws_data(type, args):
#	print(args)
	match type:
		"SL":
			if (args[0] != ""):
				for rawlobby in args:
					var lobby = Array(rawlobby.split("|"))
					print(lobby)
					var temp = LobbyTemplate.instance()
					var title_label = temp.get_node("Title")
					title_label.text = lobby[0]
					$LobbyList/Container.add_child(temp)
			else:
				pass
		"HL":
			print("Lobby created!")
			get_tree().change_scene("res://scenes/test.tscn")

func _host_lobby():
	WsClient.send("HL:%s's Lobby"%[WsClient.username])

func _process(_delta):
	material.set_shader_param("MOOD_COLOR", GlobalVars.mood_color)
	$Background.color = GlobalVars.mood_color
	$Crosshair.position = get_global_mouse_position()
	if (STATE == 0):
		if (Input.is_action_just_pressed("CONFIRM") and $PlayerInfo/Nickname.text.length() > 0):
			WsClient.username = $PlayerInfo/Nickname.text
			WsClient.send("I:"+WsClient.username)
			$PlayerInfo.visible = false
			$LobbyList.visible = true
