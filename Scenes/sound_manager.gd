class_name SoundManager
extends Node

@export var title_music: AudioStreamPlayer
@export var game_start: AudioStreamPlayer
@export var game_normal: AudioStreamPlayer
@export var game_busy: AudioStreamPlayer
@export var game_endfight: AudioStreamPlayer
@export var game_won: AudioStreamPlayer
@export var game_lost: AudioStreamPlayer


@onready var current_track: AudioStreamPlayer = title_music


func start_title() -> void:
	title_music.play()
	current_track = title_music


func start_game() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(current_track, "volume_db", -80, 1)
	tween.parallel()
	tween.tween_callback(
		func() -> void:
			current_track.stop()
			game_start.play()
			game_start.volume_db = 0
			current_track = game_start
			game_normal.play()
			game_busy.play()
			game_endfight.play()
			)
	await get_tree().create_timer(20).timeout
	if current_track == game_start:
		play_normal()


func play_won() -> void:
	_start_new_track(game_won)


func play_lost() -> void:
	_start_new_track(game_lost)


func play_busy() -> void:
	_fade_in_new_track(game_busy)


func play_endfight() -> void:
	_fade_in_new_track(game_endfight)


func play_normal() -> void:
	_fade_in_new_track(game_normal)


func _start_new_track(new_track: AudioStreamPlayer) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(current_track, "volume_db", -80, .5)
	tween.tween_callback(
		func() -> void:
			current_track.stop()
			new_track.play()
			new_track.volume_db = 0
			current_track = new_track
			)
	


func _fade_in_new_track(new_track: AudioStreamPlayer) -> void:
	if current_track == new_track:
		return
	var tween: Tween = create_tween()
	tween.tween_property(new_track, "volume_db", 0, .5)
	tween.tween_property(current_track, "volume_db", -80, .5)
	current_track = new_track
