extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0
var was_on_floor = false
var just_landed_on_floor = false

func _physics_process(delta):
	# Start of loop status vars
	if is_on_floor() and not was_on_floor:
		just_landed_on_floor = true
	else:
		just_landed_on_floor = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	if is_on_floor():
		direction = Input.get_axis("move_left", "move_right")
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# End of loop status vars
	was_on_floor = is_on_floor()
