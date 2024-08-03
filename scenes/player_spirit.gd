extends CharacterBody2D

@export var SPEED = 180.0
@export var ROLL_SPEED = 280.0
@export var JUMP_VELOCITY = -400.0
@export var MIN_ROLL_SEC = 0.4

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0
var was_on_floor = false
var just_landed_on_floor = false
var is_diving = false
var is_rolling = false
var roll_countdown = 0

@onready var ap = $AnimationPlayer;
@onready var sprite = $Sprite2D;

func _ready():
	GlobalPlayer.spirit_body = self

func _physics_process(delta):
	# Start of loop status vars
	if is_on_floor() and not was_on_floor:
		just_landed_on_floor = true
	else:
		just_landed_on_floor = false
	if is_rolling:
		roll_countdown -= delta
	if roll_countdown < 0:
		is_rolling = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if GlobalPlayer.is_controlling_spirit:
		handle_movement_input()
	
	update_animation()
	
	# End of current physics loop status vars
	was_on_floor = is_on_floor()

	move_and_slide()
	
func handle_movement_input():
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
	if is_rolling:
		velocity.x = direction * ROLL_SPEED;
	else:
		if is_on_floor():
			direction = Input.get_axis("move_left", "move_right")
		elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func start_roll():
	if not is_rolling:
		# Stay going in the same direction unless you're not moving
		is_rolling = true
		roll_countdown = MIN_ROLL_SEC

func update_animation():
	if false:
		pass
	elif !GlobalPlayer.is_controlling_spirit:
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
	
	if GlobalPlayer.is_controlling_spirit and Input.get_axis("move_left", "move_right") != 0:
		sprite.flip_h = (Input.get_axis("move_left", "move_right") == -1)
	
	#is_rolling = ap.current_animation == "roll";
