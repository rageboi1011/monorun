extends KinematicBody2D

export var WEIGHT = 40
export var FAST_FALL = 50
export var MAX_FALL = 1200
export var SPEED = 700
export var DASH_SPEED = 1200
export var ACCEL = 90
export var JUMP = 1400
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
var jump_buffer = 0
var can_jump = true
var dashing = false
var dash_buffer = 0
var joy_dir = 0
var last_dir = 1
var trails = []
var trail_amount = 7

func _process(_delta):
	if (Input.is_action_just_pressed("R")):
		if (Input.is_action_pressed("L")):
			joy_dir = -1
		else:
			joy_dir = 1
	
	if (Input.is_action_just_pressed("L")):
		if (Input.is_action_pressed("R")):
			joy_dir = 1
		else:
			joy_dir = -1
	
	if (Input.is_action_just_released("L")):
		if (Input.is_action_pressed("R")):
			joy_dir = 1
		else:
			joy_dir = 0
	
	if (Input.is_action_just_released("R")):
		if (Input.is_action_pressed("L")):
			joy_dir = -1
		else:
			joy_dir = 0
	
	if (joy_dir != 0):
		last_dir = joy_dir
	
	#----------------------------------------#
	
#	var local_pos = (get_viewport_transform().origin+$Camera.get_camera_screen_center()-(Vector2(1280,720)/2))
	var local_pos = position-(Vector2(40,40)-$Sprite.offset)
#	text_image.fill(Color("#ffffff"))
	
	if (dashing):
		trails.append({"x": $Sprite.frame_coords.x, "y": $Sprite.frame_coords.y, "flipped": $Sprite.flip_h, "pos": local_pos})
		if (trails.size() > trail_amount+1):
			trails.remove(0)
	else: 
		if (trails.size() > 0):
			trails.remove(0)
	
	#----------------------------------------#
	
	material.set_shader_param("PLAYER_COLOR", COLOR)

func _physics_process(_delta):
	grounded = (is_on_floor())
	if (grounded):
		free_timer = 0
		ground_timer += 1
		can_jump = true
	else:
		ground_timer = 0
		free_timer += 1
	
	if (is_on_ceiling()):
		bonk_timer_y += 1
		if (bonk_timer_y == 1):
			motion.y = 0
	else:
		bonk_timer_y = 0
	
	if (is_on_wall()):
		bonk_timer_x += 1
		motion.x = 0
	else:
		bonk_timer_x = 0
	
	if (ground_timer == 1 and jump_buffer == 0):
		motion.y = 0
	
	if (!grounded):
		if (motion.y + WEIGHT > MAX_FALL):
			motion.y = MAX_FALL
		else:
			var curr_ff = 0
			if (Input.is_action_pressed("D")):
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
		$Sprite.flip_h = (joy_dir == -1)
	else:
		if (grounded):
			$Anim.play("idle")
		var curr_fric = FRICTION
		if (dashing):
			curr_fric = DASH_FRICTION
		if (abs(motion.x) > 0.01):
			motion.x /= curr_fric
		else:
			motion.x = 0
	
	if (jump_buffer > 0):
		jump_buffer -= 1
	
	if (Input.is_action_just_pressed("JUMP") and can_jump):
		motion.y = -JUMP
		jump_buffer = 7
		can_jump = false
	
	if (Input.is_action_just_pressed("DASH") and grounded):
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

func _draw():
	var i = 1
	for trail in trails:
		var fade = (0.35/trail_amount)*i
		var local_pos  = (trail.pos)-get_transform().origin
		var mul = 1
		if (trail.flipped):
			mul = -1
		draw_texture_rect_region($Sprite.texture, Rect2(local_pos, Vector2(80*mul, 80)), Rect2(Vector2(80*trail.x,80*trail.y), Vector2(80, 80)), Color(fade,fade,fade))
		i += 1
