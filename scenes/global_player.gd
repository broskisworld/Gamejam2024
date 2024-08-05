extends Node

@export var DEFAULT_TO_PHYSICAL_BODY = true

signal changed_bodies_sig

var physical_body = null
var spirit_body = null
var is_controlling_physical = DEFAULT_TO_PHYSICAL_BODY
var is_controlling_spirit = !DEFAULT_TO_PHYSICAL_BODY
var just_changed_bodies = false

const SWAPPING_SOUND = preload("res://assets/sounds/swapping.mp3")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("swap_character"):
		$AudioStreamPlayer.stream = SWAPPING_SOUND
		$AudioStreamPlayer.play()
		is_controlling_physical = !is_controlling_physical
		is_controlling_spirit = !is_controlling_spirit
		just_changed_bodies = true
		changed_bodies_sig.emit()
	else:
		just_changed_bodies = false
	pass
