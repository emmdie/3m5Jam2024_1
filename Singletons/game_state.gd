@tool
extends GameStateBase

signal unit_reached_tower(unit: Unit)
signal game_restarted

var rules := GameRules.new()

# Some example variable.
var highscore := Value.new(0)
var player_health := Value.new(rules.player_max_health, false)
var enemy_health := Value.new(rules.enemy_max_health, false)
var mana := Value.new(rules.player_max_mana, false)

var unit_stash := Value.new([], false)
var selected_unit := Value.new(0, false)

signal destroy_enemy(from: Vector2)

var time_to_tower_change: float:
	get:
		return tower_switch_timer.time_left if tower_switch_timer else 0.0
var tower_switch_timer: Timer

var input_mode := Value.new(0, false) #0 = CONTROLLER, 1 = KEYBOARD

func restart():
	unit_stash.value = []
	selected_unit.reset()
	mana.reset()
	enemy_health.reset()
	player_health.reset()
	game_restarted.emit()

# Override this to change the path under which the state is saved.
func _get_file_path():
	return "user://game.state"


# Override the password used to encrypt the file.
# This password is randomly generated. You can keep it.
func _get_password():
	return "D9MEZ)5rOPyc§?§W?I%Gsxru2Q+4bEzx"


# Should the state automaticaly load on startup and save on change.
func _get_auto_save_load():
	return true

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey or event is InputEventMouse:
		if input_mode.value != 1:
			input_mode.value = 1
	else:
		if input_mode.value != 0:
			input_mode.value = 0
