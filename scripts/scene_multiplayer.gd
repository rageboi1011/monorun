extends Node2D

const STATES = {
	0: "input_name",
	1: "choose_lobby"
}

var STATE = 0

func _ready():
#	print(MonoBase.toDec("0vC5"))
	print(MonoBase.fromHex("#FFFFFF"))
	print(MonoBase.fromHex("024aca"))
	print(MonoBase.fromHex("24aca"))
#	print(MonoBase.fromDec(150218))
#	print(MonoBase.toHex("0vC5"))

func _process(_delta):
	material.set_shader_param("MOOD_COLOR", GlobalVars.mood_color)
	$Background.color = GlobalVars.mood_color
	$Crosshair.position = get_global_mouse_position()
	if (STATE == 0):
		if (Input.is_action_just_pressed("CONFIRM") and $PlayerInfo/Nickname.text.length() > 0):
			$PlayerInfo.visible = false
			$LobbyList.visible = true
