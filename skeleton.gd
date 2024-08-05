extends CharacterBody2D


@export var PATROL_POINT_A: Node2D
@export var PATROL_POINT_B: Node2D
@export var SPEED = 30.0
@export var ATTACK_COOLDOWN_SEC = 1.8
@export var TIME_TO_DAMAGE = 0.9
@export var ATTACK_DAMAGE = 2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_going_to_point_a = false
var is_attacking = false
var attack_cooldown_count = 0
var attack_damage_cooldown_count = TIME_TO_DAMAGE

func _physics_process(delta):
	if Global.game_over:
		return
	
	attack_cooldown_count -= delta
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Do we see anyone?
	if $Area2D.get_overlapping_bodies().size() > 0:
		is_attacking = true
		attack_damage_cooldown_count -= delta
		
		if attack_damage_cooldown_count < 0 and attack_cooldown_count < 0:
			for i in range($Area2D.get_overlapping_bodies().size()):
				$Area2D.get_overlapping_bodies()[i].hurt(ATTACK_DAMAGE)
				attack_cooldown_count = ATTACK_COOLDOWN_SEC
				attack_damage_cooldown_count = TIME_TO_DAMAGE
		
		
	else:
		is_attacking = false
		attack_damage_cooldown_count = TIME_TO_DAMAGE
	
	if is_attacking:
		pass
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		if is_going_to_point_a and position.x < PATROL_POINT_A.position.x:
			is_going_to_point_a = false
			$Area2D/CollisionShape2D.position.x *= -1
		elif not is_going_to_point_a and position.x > PATROL_POINT_B.position.x:
			is_going_to_point_a = true
			$Area2D/CollisionShape2D.position.x *= -1
		
		if is_going_to_point_a:
			velocity.x = -SPEED
			$Sprite2D.flip_h = true
			$Sprite2D.offset.x = -19
		else:
			velocity.x = SPEED
			$Sprite2D.flip_h = false
			$Sprite2D.offset.x = 0
			

	move_and_slide()
	
	update_animations()

func update_animations():
	if is_attacking:
		$AnimationPlayer.play("attack")
	else:
		$AnimationPlayer.play("walk")
