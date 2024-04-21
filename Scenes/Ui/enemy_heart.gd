extends MarginContainer
@export var enemy_icon:Texture
@export var player_icon:Texture
@onready var animator = $Node2D/Texture/AnimationPlayer
@onready var icon = $Node2D/Texture

func _ready() -> void:
	randomize_playback_speed()

func randomize_playback_speed():
	animator.speed_scale = randf_range(0.7, 1.5)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	randomize_playback_speed()

func make_player():
	icon.texture = player_icon

func make_enemy():
	icon.texture = enemy_icon
