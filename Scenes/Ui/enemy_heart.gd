extends MarginContainer
@export var enemy_icon:Texture
@export var player_icon:Texture
@onready var animator = $Node2D/Texture/AnimationPlayer
@onready var icon = $Node2D/Texture

@onready var animated_sprite := $Node2D/Control/AnimatedSpriteEnemy

func _ready() -> void:
	randomize_playback_speed()
	animated_sprite.show()

func explode() -> void:
	$Node2D/Texture.modulate.a = 0.0
	$Node2D/Control.show()
	animated_sprite.play("default")
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0, 0.3).set_delay(0.2)

func randomize_playback_speed():
	animator.speed_scale = randf_range(0.7, 1.5)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	randomize_playback_speed()

func make_player():
	icon.texture = player_icon
	animated_sprite.hide()
	animated_sprite = $Node2D/Control/AnimatedSpritePlayer
	animated_sprite.show()

func make_enemy():
	icon.texture = enemy_icon
	animated_sprite.hide()
	animated_sprite = $Node2D/Control/AnimatedSpriteEnemy
	animated_sprite.show()
