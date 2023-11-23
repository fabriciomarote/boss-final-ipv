extends Node

onready var sfx_container: Node = $SfxContainer

export (String) var default_bus: String = "General"

var streams_list: Array = []


func play_sfx(audio:AudioStream, audio_bus: String, db:float = 0.0, pitch_scale:float = 1.0)->void:
	var stream:AudioStreamPlayer = AudioStreamPlayer.new()
	stream.connect("finished", self, "_on_sfx_stream_finished")
	stream.stream = audio
	stream.volume_db = db
	stream.pitch_scale = pitch_scale
	stream.bus = audio_bus if !audio_bus.empty() else default_bus
	sfx_container.add_child(stream)
	stream.call_deferred("play")
	streams_list.push_back(stream)


func _on_sfx_stream_finished() -> void:
	for stream in streams_list.duplicate():
		if !stream.playing:
			streams_list.erase(stream)
			call_deferred("_remove_stream", stream)


func _remove_stream(stream: AudioStreamPlayer) -> void:
	sfx_container.remove_child(stream)
	stream.queue_free()
