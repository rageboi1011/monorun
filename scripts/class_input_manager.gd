extends Node

class_name InputManager

signal pressed(key)
signal released(key)

var type = -1

# Make Player Script more Event-Based to SOLVE EVERY FUCKING PROBLEM ON JAWN

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

func _check():
	for key in keys:
		if (keys[key] == 1):
			keys[key] = 3
#			print(str(key)+"==>"+str(keys[key]))
#			print("i:" + str(key) + str(3))
		if (keys[key] == 2):
			keys[key] = 0
#			print(str(key)+"==>"+str(keys[key]))
#			print("i:" + str(key) + str(0))

func _update(_delta):
	if (type == 0):
#		_check()
		for key in keys:
#			var val = 0
#			if (Input.is_action_pressed(key)):
#				val = 3
			if (Input.is_action_just_pressed(key)):
#				val = 1
				keys[key] = 1
				emit_signal("pressed", key, 1)
#				print(str(key)+"==>"+str(keys[key]))
				yield(get_tree(), "idle_frame")
				if (keys[key] == 1):
					keys[key] = 3
#					print(str(key)+"==>"+str(keys[key]))
			if (Input.is_action_just_released(key)):
#				val = 2
				keys[key] = 2
				emit_signal("released", key, 2)
#				print(str(key)+"==>"+str(keys[key]))
				yield(get_tree(), "idle_frame")
				if (keys[key] == 2):
					keys[key] = 0
#					print(str(key)+"==>"+str(keys[key]))

func is_pressed(key):
	return (keys[key] == 1)

func is_released(key):
	return (keys[key] == 2)

func is_down(key):
	return (keys[key] == 3 or keys[key] == 1)

func decode(string):
	var states = Array(string.split(""))
	var ind = keys.keys()[states[0]]
	keys[ind] = states[1]

#func encode():
#	var string = PoolStringArray([])
#	for key in keys:
#		string.append(keys[key])
#	return string.join("")

func _on_input(key, state):
	if (WsClient.connected):
#		var encoded = encode()
		var sock_string = "i:" + str(key) + str(state)
#		print(sock_string)
#		print(str(key)+"==>"+str(keys[key]))
		WsClient.send(sock_string)

func _on_pressed(key, _val):
	pass

func _on_released(key, _val):
	pass

func get_tree():
	return GlobalVars.tree
