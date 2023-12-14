extends Node

export (String) var bgm_bus: String

export (AudioStream) var starting_bgm: AudioStream
export (float) var starting_db: float = 0.0
export (float) var starting_pitch: float = 1.0

var current_stream: AudioStreamPlayer
var current_db: float = 0.0

var xfade_tween: SceneTreeTween


func _ready() -> void:
	if starting_bgm:
		play(starting_bgm, starting_db, starting_pitch)


func play(
		stream: AudioStream,
		db: float = 0.0,
		pitch: float = 1.0,
		xfade_time: float = 1.0
	)-> void:
	if current_stream != null && stream == current_stream.stream && current_db == db && current_stream.pitch_scale == pitch:
		return
	
	var prev_stream = current_stream
	
	current_stream = AudioStreamPlayer.new()
	add_child(current_stream)
	current_stream.stream = stream
	current_stream.volume_db = -80.0
	current_db = db
	current_stream.pitch_scale = pitch
	current_stream.bus = bgm_bus
	current_stream.play()
	
	if xfade_tween:
		xfade_tween.kill()
		_cleanup(prev_stream)
	
	xfade_tween = create_tween()
	
	if prev_stream:
		if prev_stream.stream == stream:
			current_stream.volume_db = prev_stream.volume_db
			current_stream.play(prev_stream.get_playback_position())
		xfade_tween.tween_property(prev_stream, "volume_db", -80.0, xfade_time)
	xfade_tween.set_parallel().tween_property(current_stream, "volume_db", db, xfade_time)
	
	if prev_stream:
		xfade_tween.set_parallel(false).tween_callback(self, "_cleanup")


func _cleanup(exclude: Node = null) -> void:
	for stream in get_children():
		if !stream in [current_stream, exclude]:
			remove_child(stream)
			stream.queue_free()
