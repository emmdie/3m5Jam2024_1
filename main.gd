extends Node

@export var current_game_scene: Game
@export var title_screen: Control
@export var sound_manager: SoundManager
@export var win_menu: Control
@export var lose_menu: Control

@onready var start_button = $Title/VBoxContainer/Start 
@onready var animator = $AnimationPlayer
@onready var licenses = $Title/LicenseViewer
@onready var how_to_play = $Title/HowToPlay

func _ready() -> void:
	sound_manager.start_title()
	GameState.game_restarted.connect(_restart)
	_connect_current_game_scene()
	start_button.grab_focus()
	


func _connect_current_game_scene() -> void:
	current_game_scene.game_won.connect(_game_won)
	current_game_scene.game_lost.connect(_game_lost)


func _restart() -> void:
	var new_game: Game = preload("res://Scenes/game.tscn").instantiate()
	current_game_scene.queue_free()
	current_game_scene = new_game
	current_game_scene.sound_manager = sound_manager
	_connect_current_game_scene()
	add_child(new_game)
	new_game.start_game()
	win_menu.hide()
	lose_menu.hide()

func _game_won() -> void:
	current_game_scene.set_process_input(false)
	win_menu.show()

func _game_lost() -> void:
	current_game_scene.set_process_input(false)
	lose_menu.show()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	licenses.visible = true

func _on_start_pressed() -> void:
	animator.play("fade_title")
	current_game_scene.start_game()
	
func _on_git_hub_pressed() -> void:
	OS.shell_open("https://github.com/emmdie/3m5Jam2024_1")


func _on_how_to_play_pressed() -> void:
	how_to_play.visible = true
	how_to_play.grab_focus()

func _on_hide_button_pressed() -> void:
	how_to_play.visible = false
	start_button.grab_focus()
