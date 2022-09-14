extends Node

var managers = []

func _process(delta):
	for manager in managers:
		manager._update(delta)
