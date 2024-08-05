extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	GlobalPlayer.physical_body.die_sig.connect(on_die)
	GlobalPlayer.spirit_body.die_sig.connect(on_die)
	pass # Replace with function body.

func on_die():
	visible = true
	$Camera2D.make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
		
