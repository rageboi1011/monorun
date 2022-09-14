extends Node

class_name InputManager

signal pressed(key)
signal released(key)

var type = -1

var keys = {
	"U": 0,
	"D": 0,
	"L": 0,
	"R": 0,
	"DASH": 0,
	"JUMP": 0
}

func _init(t):
	type = t
	GlobalInputManager.managers.append(self)
	#######
	connect("pressed", self, "_on_input")
	connect("released", self, "_on_input")
	connect("pressed", self, "_on_pressed")
	connect("released", self, "_on_released")

func _update(_delta):
	if (type == 0):
		for key in keys:
			var val = 0
			if (Input.is_action_pressed(key)):
				val = 3
			if (Input.is_action_just_pressed(key)):
				val = 1
				emit_signal("pressed", key)
			if (Input.is_action_just_released(key)):
				val = 2
				emit_signal("released", key)
			keys[key] = val
#	print(Inputs.keys)

func is_pressed(key):
	return (keys[key] == 1)

func is_released(key):
	return (keys[key] == 2)

func is_down(key):
	return (keys[key] == 3 or keys[key] == 1)

func decode(string):
	var states = Array(string.split(""))
	var key_names = keys.keys()
	var i = 0
	for state in states:
		keys[key_names[i]] = state
		i += 1

func encode():
	var string = PoolStringArray([])
	for key in keys:
		string.append(keys[key])
	return string.join("")

func _on_input(key):
	if (WsClient.connected):
		var encoded = encode()
		WsClient.send("i:" + str(encoded))

func _on_pressed(key):
	pass

func _on_released(key):
	pass
