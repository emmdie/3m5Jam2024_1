extends Node

@export var current_game_scene: Game
@export var title_screen: Control
@export var sound_manager: SoundManager

func _ready() -> void:
	sound_manager.start_title()




func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	pass # Replace with function body.

func _on_start_pressed() -> void:
	title_screen.hide()
	current_game_scene.start_game()

