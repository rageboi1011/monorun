extends Node

class_name InputManager

signal pressed(key)
signal released(key)

var type = -1

# Make Player Script more Event-Based to SOLVE EVERY FUCKING PROBLEM ON JAWN

const TO_BOOL = {
	1: true,
	2: false
}

var keys = {
	"U": false,
	"D": false,
	"L": false,
	"R": false,
	"DASH": false,
	"JUMP": false
}

func _init(t):
	type = t
	GlobalInputManager.managers.append(self)
	#######
	connect("pressed", self, "_on_pressed")
	connect("released", self, "_on_released")

func _update(_delta):
	if (type == 0):
#		_check()
		for key in keys:
			if (Input.is_action_just_pressed(key)):
				_handle_press(key)
			if (Input.is_action_just_released(key)):
				_handle_release(key)

func is_down(key):
	return keys[key]

func decode(string):
	var states = Array(string.split(""))
	var ind = keys.keys()[states[0]]
	keys[ind] = TO_BOOL[states[1]]

func _handle_press(key):
	yield(get_tree().create_timer(0.001*WsClient.ping), "timeout")
	emit_signal("pressed", key)
	keys[key] = true

func _handle_release(key):
	yield(get_tree().create_timer(0.001*WsClient.ping), "timeout")
	emit_signal("released", key)
	keys[key] = false

func _on_pressed(key):
	_on_input(key, 1)

func _on_released(key):
	_on_input(key, 2)

func _on_input(key, state):
	if (WsClient.connected):
		var sock_string = "i:" + str(key) + str(state)
		WsClient.send(sock_string)

func get_tree():
	return GlobalVars.tree
