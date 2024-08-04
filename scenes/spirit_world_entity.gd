extends Node2D

@onready var canvas_item = $CanvasModulate

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalPlayer.changed_bodies_sig.connect(on_swapped_bodies)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_swapped_bodies():
	if GlobalPlayer.is_controlling_spirit:
		modulate.a = 1.0
	else:
		modulate.a = 0.1
