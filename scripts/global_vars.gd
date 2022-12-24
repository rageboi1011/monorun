extends Node

const MOODS = [
	"000000",
	"151515",
	"0d2030",
	"231712",
	"211640",
	"172808",
]

var temp_plr_info = []

export var mood_color =  Color(MOODS[0])
var current_camera = null

onready var tree = get_tree()

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rand = rng.randi() % 6
	print(rand)
	mood_color = Color(MOODS[rand])

func _process(delta):
	pass
