extends Node

@export var current_game_scene: Game
@export var title_screen: Control
@export var sound_manager: SoundManager
@export var win_menu: Control
@export var lose_menu: Control

func _ready() -> void:
	sound_manager.start_title()
	GameState.game_restarted.connect(_restart)
	_connect_current_game_scene()


func _connect_current_game_scene() -> void:
	current_game_scene.game_won.connect(_game_won)
	current_game_scene.game_lost.connect(_game_lost)


func _restart() -> void:
	var new_game: Game = preload("res://Scenes/game.tscn").instantiate()
	current_game_scene.queue_free()
	current_game_scene = new_game
	_connect_current_game_scene()
	add_child(new_game)
	new_game.start_game()
	win_menu.hide()
	lose_menu.hide()

func _game_won() -> void:
	win_menu.show()

func _game_lost() -> void:
	lose_menu.hide()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	pass # Replace with function body.

func _on_start_pressed() -> void:
	title_screen.hide()
	current_game_scene.start_game()

