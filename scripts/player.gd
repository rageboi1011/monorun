extends KinematicBody2D

signal trail_cont

export var type = 0

export var WEIGHT = 40
export var FAST_FALL = 50
export var MAX_FALL = 1200
export var SPEED = 700
export var DASH_SPEED = 1200
export var ACCEL = 90
export var JUMP = 1300
export var FRICTION = 1.2
export var DASH_FRICTION = 1.04
export var COLOR = Color("#e03c28")

const UP = Vector2(0, -1)

var motion = Vector2(0, 0)
var add_motion = Vector2(0, 0)
var grounded = true
var ground_timer = 0
var bonk_timer_y = 0
var bonk_timer_x = 0
var free_timer = 0
var jump_pending = false
var jump_buffer = 0
var max_jumps = 1
var jumps = max_jumps
var dash_pending = false
var dashing = false
var dash_buffer = 0
var joy_dir = 0
var last_dir = 1
var trails = []
var trail_amount = 7

var TRAIL_CONT = null
var VELOCITY = {
	"SPEED": 0,
	"ANGLE": 0
}

var Inputs = InputManager.new(type)

func spawn_trail():
	if (TRAIL_CONT != null):
		var sprite = $Sprite.duplicate(8)
		TRAIL_CONT.add_child(sprite)
		sprite.position = (position+$Sprite.position)
		sprite.frame_coords = $Sprite.frame_coords
		var fade = 0.35
		var fade_time = 0.1
		var tween = Tween.new()
		sprite.add_child(tween)
		tween.interpolate_property(sprite, "modulate", Color(1,1,1,fade), Color(1,1,1,0), fade_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(get_tree().create_timer(fade_time), "timeout")
		sprite.queue_free()

func _ready():
	Inputs.connect("pressed", self, "_input_press")
	Inputs.connect("released", self, "_input_release")
	
	if (type == 0):
		$Camera.current = true
		GlobalVars.current_camera = $Camera
	material = material.duplicate(8)
	connect("trail_cont", self, "_got_trail_cont")
	if (!OS.is_debug_build() or true):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
#		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input_press(key):
	if (key == "R"):
		joy_dir = 1
	if (key == "L"):
		joy_dir = -1
	if (key == "JUMP"):
		jump_pending = true
	if (key == "DASH"):
		dash_pending = true

func _input_release(key):
	if (key == "R"):
		if (!Inputs.is_down("L")):
			joy_dir = 0
		else:
			joy_dir = -1
	if (key == "L"):
		if (!Inputs.is_down("R")):
			joy_dir = 0
		else:
			joy_dir = 1

func _got_trail_cont(trail_cont):
	TRAIL_CONT = trail_cont

func _process(_delta):
	var mouse_screen_pos = get_global_mouse_position()
	var screen_pos = get_transform().get_origin()
#	print("CAMERA: ", $Camera.get_camera_position())
	$Sprite.flip_h = (mouse_screen_pos.x < screen_pos.x)
	
	if (joy_dir != 0):
		last_dir = joy_dir
	
	
	#----------------------------------------#
	
	if  (VELOCITY.SPEED > 1000):
		spawn_trail()
	
	#----------------------------------------#
	
	material.set_shader_param("PLAYER_COLOR", COLOR)
	material.set_shader_param("MOOD_COLOR", GlobalVars.mood_color)

func _physics_process(_delta):
	VELOCITY.SPEED = sqrt(pow(motion.x, 2)+pow(motion.y, 2))
	VELOCITY.ANGLE = atan2(motion.y, motion.x)
	grounded = (is_on_floor())
	if (grounded):
		jump_buffer = 5
		free_timer = 0
		ground_timer += 1
		jumps = max_jumps
	else:
		jump_buffer -= 1
		ground_timer = 0
		free_timer += 1
	
	if (is_on_ceiling()):
		bonk_timer_y += 1
		if (bonk_timer_y == 1):
			motion.y *= -0.25
	else:
		bonk_timer_y = 0
	
	if (is_on_wall()):
		bonk_timer_x += 1
		motion.x = 0
		var collide = get_last_slide_collision()
		var ang = rad2deg(atan2(collide.normal.y, collide.normal.x))
		var dir = 1
		if (ang == 180):
			dir = -1
		if ((dir == -1) == $Sprite.flip_h):
			motion.y = 200
			if (Input.is_action_just_pressed("JUMP") and (ang == 180 or ang == 0)):
				motion.y = -JUMP*0.9
				motion.x = (DASH_SPEED/1.2)*dir
	else:
		bonk_timer_x = 0
	
	if (ground_timer == 1):
		motion.y = 0
	
	if (!grounded):
		if (jumps > max_jumps-1 and jump_buffer == 0):
			jumps = max_jumps-1
		if (motion.y + WEIGHT > MAX_FALL):
			motion.y = MAX_FALL
		else:
			var curr_ff = 0
			if (Inputs.is_down("D")):
				curr_ff = FAST_FALL
			motion.y += (WEIGHT+curr_ff)
	#----------------------------------------#
		if (motion.y < 0):
			if (motion.y > -400):
				$Anim.play("jump_peak")
			else:
				$Anim.play("jump")
		else:
			$Anim.play("fall")
	
	if joy_dir != 0:
		var div = 2.3
		if (grounded): 
			$Anim.play("run")
			div = 1
		motion.x += (ACCEL*joy_dir)/div
#		$Sprite.flip_h = (joy_dir == -1)
	else:
		if (grounded):
			$Anim.play("idle")
		var curr_fric = FRICTION
		if (dashing):
			curr_fric = DASH_FRICTION
		if (!grounded):
			curr_fric = 1.009
		if (abs(motion.x) > 0.01):
			motion.x /= curr_fric
		else:
			motion.x = 0
	
	if (jump_pending):
		jump_pending = false
		if (jumps > 0):
			motion.y = -JUMP
			jumps -= 1
	
	if (dash_pending):
		dash_pending = false
		if (grounded):
			motion.x = (DASH_SPEED*last_dir)
			dashing = true
	
	if (abs(motion.x) < SPEED and grounded):
		dashing = false
#	if (dash_buffer > 0):
#		dash_buffer -= 1
#		dashing = true
#	else:
#		dashing = false
	
	if (dashing):
		motion.x = clamp(motion.x, -DASH_SPEED, DASH_SPEED)
	else:
		motion.x = clamp(motion.x, -SPEED, SPEED)
	
	move_and_slide((motion+add_motion), UP, false, 4, 0)
#	position = position.snapped(Vector2(5,5))
	update()

func global_to_screen(vec2):
	var camera_pos = ($Camera.get_camera_screen_center())
	print($Camera.get_camera_screen_center())
	if (camera_pos != null):
		return camera_pos - vec2
	else:
		return null
