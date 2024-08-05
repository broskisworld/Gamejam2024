extends AudioStreamPlayer

var playlist_physical = []
var playlist_spirit = []
var playing_index = 0
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	playlist_physical.append(preload("res://assets/friend_bosley/game - towered DAY.mp3"))
	playlist_spirit.append(preload("res://assets/friend_bosley/game - towered NIGHT.mp3"))
	playlist_physical.append(preload("res://assets/friend_bosley/game - courage DAY.mp3"))
	playlist_spirit.append(preload("res://assets/friend_bosley/game - courage NIGHT.mp3"))
	playlist_physical.append(preload("res://assets/friend_bosley/game tutorial - beauty DAY.mp3"))
	playlist_spirit.append(preload("res://assets/friend_bosley/game tutorial - beauty NIGHT.mp3"))
	
	
	playing_index = rng.randi_range(0, playlist_physical.size() - 1)
	stream = playlist_physical[playing_index]
	play(rng.randf_range(0.0, stream.get_length()))
	
	GlobalPlayer.changed_bodies_sig.connect(on_changed_bodies)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_playing():
		if GlobalPlayer.is_controlling_physical:
			stream = playlist_physical[playing_index + 1 % (playlist_physical.size() - 1)]
		else:
			stream = playlist_spirit[playing_index + 1 % (playlist_spirit.size() - 1)]
		play()

func on_changed_bodies():
	if GlobalPlayer.is_controlling_physical:
		var cur_pos = get_playback_position()
		stream = playlist_physical[playing_index]
		play(cur_pos)
	else:
		var cur_pos = get_playback_position()
		stream = playlist_spirit[playing_index]
		play(cur_pos)
