extends Area2D

@export var DEFAULT_ACTIVATED = false
@export var PHYSICAL_BODY_CAN_USE = true
@export var SPIRIT_BODY_CAN_USE = true
@export var ACTIVATE_BODES: Array[Node2D]

signal active_changed

var active = DEFAULT_ACTIVATED

# Called when the node enters the scene tree for the first time.
func _ready():
	update_bodies()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("use"):
		if PHYSICAL_BODY_CAN_USE and get_overlapping_bodies().find(GlobalPlayer.physical_body) != -1:
			active = !active
			$Sprite2D.frame_coords.x = 5 if active else 4
			$AudioStreamPlayer.play()
			update_bodies()
			active_changed.emit()
		if SPIRIT_BODY_CAN_USE and get_overlapping_bodies().find(GlobalPlayer.spirit_body) != -1:
			active = !active
			$Sprite2D.frame_coords.x = 5 if active else 4
			$AudioStreamPlayer.play()
			update_bodies()
			active_changed.emit()

func update_bodies():
	for body in ACTIVATE_BODES:
		if active:
			body.show()
		else:
			body.hide()
	pass
