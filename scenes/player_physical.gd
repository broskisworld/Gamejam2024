extends CharacterBody2D

@export var SPEED = 180.0
@export var ROLL_SPEED = 280.0
@export var JUMP_VELOCITY = -400.0
@export var MIN_ROLL_SEC = 0.4
@export var WALL_JUMP_VELOCITY = Vector2(400.0, -400.0)
@export var STARTING_HEALTH = 6

# Health & progression
var health = STARTING_HEALTH
signal health_change_sig
signal die_sig

# Physics & controls
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0
var was_on_floor = false
var just_landed_on_floor = false
var is_diving = false
var is_rolling = false
var roll_countdown = 0
var is_wall_jumping = false
var wall_jump_control_lock = false

@onready var ap = $AnimationPlayer;
@onready var sprite = $Sprite2D;

func _ready():
	GlobalPlayer.physical_body = self
	GlobalPlayer.changed_bodies_sig.connect(on_swapped_bodies)

func _physics_process(delta):
	# Start of loop status vars
	if is_on_floor():
		is_wall_jumping = false
		wall_jump_control_lock = false
	if is_on_floor() and not was_on_floor:
		just_landed_on_floor = true
	else:
		just_landed_on_floor = false
	if is_rolling:
		roll_countdown -= delta
	if roll_countdown < 0:
		is_rolling = false
	if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
		wall_jump_control_lock = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if GlobalPlayer.is_controlling_physical:
		handle_movement_input()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	update_animation()
	
	# End of current physics loop status vars
	was_on_floor = is_on_floor()

	move_and_slide()
	
func handle_movement_input():
	# Debug: decrement health
	if Input.is_action_just_pressed("debug_health"):
		hurt(1)
	
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle dives
	if Input.is_action_pressed("move_down") and not is_on_floor():
		is_diving = true
	else:
		is_diving = false
	
	# Are we starting a roll?
	if is_on_floor() and velocity.x != 0 and Input.is_action_just_pressed("move_down"):
		direction = 1 if velocity.x > 0 else -1
		start_roll()
	if just_landed_on_floor and Input.is_action_pressed("move_down") and (Input.get_axis("move_left", "move_right") != 0):
		direction = Input.get_axis("move_left", "move_right")
		start_roll()

	# Get the input direction and handle the movement/deceleration.
	if is_wall_jumping:
		if wall_jump_control_lock:
			pass
		elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			direction = Input.get_axis("move_left", "move_right")
	elif is_rolling:
		velocity.x = direction * ROLL_SPEED;
	else:
		if is_on_floor():
			direction = Input.get_axis("move_left", "move_right")
		elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			direction = Input.get_axis("move_left", "move_right")
			
			if Input.is_action_just_pressed("jump") and not is_wall_jumping:
				if $WallJumpDetectLeft.get_overlapping_bodies().size() > 0 and $WallJumpDetectRight.get_overlapping_bodies().size() > 0:
					if Input.get_axis("move_left", "move_right") != 0:
						direction = -Input.get_axis("move_left", "move_right")
						start_wall_jump()
				elif $WallJumpDetectLeft.get_overlapping_bodies().size() > 0:
					direction = 1
					start_wall_jump()
				elif $WallJumpDetectRight.get_overlapping_bodies().size() > 0:
					direction = -1
					start_wall_jump()
		if direction and not is_wall_jumping:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func on_swapped_bodies():
	if GlobalPlayer.is_controlling_physical:
		sprite.modulate.a = 1.0
	else:
		sprite.modulate.a = 0.9

func start_roll():
	if not is_rolling:
		# Stay going in the same direction unless you're not moving
		is_rolling = true
		roll_countdown = MIN_ROLL_SEC

func start_wall_jump():
	if not is_wall_jumping:
		is_wall_jumping = true
		velocity.y = WALL_JUMP_VELOCITY.y
		velocity.x = direction * WALL_JUMP_VELOCITY.x
		wall_jump_control_lock = true

func heal(amt):
	health += amt
	# TODO: play heal sound
	health_change_sig.emit()

func hurt(amt):
	health -= amt
	$HealthSprite.frame_coords.y = 6 - health
	# TODO: play hurt sound
	
	if health <= 0:
		die()
	else:
		health_change_sig.emit()

func die():
	die_sig.emit()
	get_tree().set_current_scene(preload("res://scenes/death_ui.tscn").instantiate())

func update_animation():
	if false:
		pass
	elif !GlobalPlayer.is_controlling_physical:
		if GlobalPlayer.just_changed_bodies:
			ap.play("meditate_start")
		else:
			ap.play("meditate")
	elif is_rolling:
		ap.play("roll")
	elif velocity.y < 0:
		ap.play("jump_up")
	elif velocity.y > 0:
		ap.play("jump_down")
	elif velocity.x != 0:
		ap.play("run")
	else:
		ap.play("idle")
	
	if GlobalPlayer.is_controlling_physical:
		if Input.get_axis("move_left", "move_right") != 0:
			sprite.flip_h = (Input.get_axis("move_left", "move_right") == -1)
		elif is_wall_jumping:
			sprite.flip_h = direction == -1
	
	#is_rolling = ap.current_animation == "roll";
