extends MarginContainer

@onready var animator = $Node2D/Texture/AnimationPlayer

func _ready() -> void:
	randomize_playback_speed()

func randomize_playback_speed():
	animator.speed_scale = randf_range(0.7, 1.5)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	randomize_playback_speed()
