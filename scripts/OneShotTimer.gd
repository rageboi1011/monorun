extends Node

var timers = {}
var count = 0

func start(time):
	var id = count
	count += 1
	timers[id] = Timer.new()
	timers[id].process_mode = 1
	timers[id].one_shot = true
	get_tree().current_scene.add_child(timers[id])
	timers[id].start(time)
	
	timers[id].connect("timeout", self, "_timeout", [id])
	
	return timers[id]

func _timeout(id):
	timers[id].queue_free()
	timers.erase(id)
