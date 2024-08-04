extends CharacterBody2D

@export var SPEED = 180.0
@export var ROLL_SPEED = 280.0
@export var DASH_SPEED = 650.0
@export var JUMP_VELOCITY = -400.0
@export var MIN_ROLL_SEC = 0.4
@export var MIN_DASH_SEC = 0.1
@export var COMBO_TIMEOUT = 0.3
@export var MAX_COMBO_CHAIN = 2 # Maximum key presses in a combo

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0
var was_on_floor = false
var just_landed_on_floor = false
var is_diving = false
var is_rolling = false
var roll_countdown = 0
var allow_dash = true
var is_dashing = false
var last_key_delta = 0    # Time since last keypress
var dash_countdown = 0
var key_combo = []        # Current combo

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var dash_particles = $CPUParticles2D

func _ready():
	GlobalPlayer.spirit_body = self
	GlobalPlayer.changed_bodies_sig.connect(on_swapped_bodies)

func _input(event):
	if event is InputEventKey and event.pressed and !event.echo: # If distinct key press down
		if last_key_delta > COMBO_TIMEOUT:                   # Reset combo if stale
			key_combo = ""
		
		key_combo += event.as_text()                         # Otherwise add it to combo
		if key_combo.length() > MAX_COMBO_CHAIN:               # Prune if necessary
			key_combo = key_combo.substr(1)
		
		print(key_combo)                                     # Log the combo (could pass to combo evaluator)
		last_key_delta = 0                                   # Reset keypress timer

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
	if is_dashing:
		dash_countdown -= delta
	if dash_countdown < 0:
		is_dashing = false
	last_key_delta += delta
	if last_key_delta > COMBO_TIMEOUT:
		key_combo = ""
	
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta
	
	if GlobalPlayer.is_controlling_spirit:
		handle_movement_input()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
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
	if not (is_dashing or is_rolling) and is_on_floor() and velocity.x != 0 and Input.is_action_just_pressed("move_down"):
		direction = 1 if velocity.x > 0 else -1
		start_roll()
	if not (is_dashing or is_rolling) and just_landed_on_floor and Input.is_action_pressed("move_down") and (Input.get_axis("move_left", "move_right") != 0):
		direction = Input.get_axis("move_left", "move_right")
		start_roll()
	
	# Are we starting a dash?
	if allow_dash and key_combo == "AA" and not (is_rolling or is_dashing):
		direction = -1
		start_dash()
		print("Start dash!")
	elif allow_dash and key_combo == "DD" and not (is_rolling or is_dashing):
		direction = 1
		start_dash()
		print("Start dash!")

	# Get the input direction and handle the movement/deceleration.
	if is_rolling:
		velocity.x = direction * ROLL_SPEED;
	elif is_dashing:
		velocity.x = direction * DASH_SPEED;
		print("Dashing!!!")
	else:
		if is_on_floor():
			direction = Input.get_axis("move_left", "move_right")
		elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func on_swapped_bodies():
	if GlobalPlayer.is_controlling_spirit:
		sprite.modulate.a = 1.0
	else:
		sprite.modulate.a = 0.9

func start_roll():
	if not is_rolling:
		# Stay going in the same direction unless you're not moving
		is_rolling = true
		roll_countdown = MIN_ROLL_SEC

func start_dash():
	if not is_dashing:
		# Stay going in the same direction unless you're not moving
		is_dashing = true
		dash_countdown = MIN_DASH_SEC

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
	
	if is_dashing:
		dash_particles.emitting = true
		dash_particles.direction.x = -direction
	else:
		dash_particles.emitting = false
	
	if GlobalPlayer.is_controlling_spirit and Input.get_axis("move_left", "move_right") != 0:
		sprite.flip_h = (Input.get_axis("move_left", "move_right") == -1)
	
	#is_rolling = ap.current_animation == "roll";
