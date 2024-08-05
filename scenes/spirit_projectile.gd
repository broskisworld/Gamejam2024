extends CharacterBody2D

@export var PROJECTILE_SPEED = 300.0
var direction = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.flip_h = (direction == -1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.x = direction * PROJECTILE_SPEED
	
	move_and_slide()
	
	var hits = $Area2D.get_overlapping_bodies()
	
	if $Area2D.get_overlapping_bodies().size() > 0:
		explode()

func explode():
	queue_free()
