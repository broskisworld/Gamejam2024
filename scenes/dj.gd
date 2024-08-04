extends AudioStreamPlayer

var playlist_physical = []
var playlist_spirit = []
var playing_index = 0
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	playlist_physical.append(preload("res://assets/brumodoubled/beauty_day_v2_demo.mp3"))
	playlist_spirit.append(preload("res://assets/brumodoubled/beauty_night_v2_demo.mp3"))
	
	GlobalPlayer.changed_bodies_sig.connect(on_changed_bodies)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_playing():
		stream = playlist_physical[playing_index]
		play(rng.randf_range(0.0, stream.get_length()))

func on_changed_bodies():
	if GlobalPlayer.is_controlling_physical:
		var cur_pos = get_playback_position()
		stream = playlist_physical[playing_index]
		play(cur_pos)
	else:
		var cur_pos = get_playback_position()
		stream = playlist_spirit[playing_index]
		play(cur_pos)
