extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalPlayer.changed_bodies_sig.connect(on_swapped_bodies)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x = (GlobalPlayer.physical_body.position.x + GlobalPlayer.spirit_body.position.x) * 0.5
	position.y = (GlobalPlayer.physical_body.position.y + GlobalPlayer.spirit_body.position.y) * 0.5

func on_swapped_bodies():
	if GlobalPlayer.is_controlling_physical:
		#visibility_layer = 1
		#SubViewport.
		pass
	else:
		#visibility_layer = 9
		pass
