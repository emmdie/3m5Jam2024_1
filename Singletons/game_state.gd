@tool
extends GameStateBase

signal unit_reached_tower(unit: Unit)

var rules := GameRules.new()

# Some example variable.
var highscore := Value.new(0)
var player_health := Value.new(rules.player_max_health, false)
var enemy_health := Value.new(rules.enemy_max_health, false)
var mana := Value.new(rules.player_max_mana, false)

var unit_stash := Value.new([], false)
var selected_unit := Value.new(0, false)

var time_to_tower_change: float:
	get:
		return tower_switch_timer.time_left
@onready var tower_switch_timer: SceneTreeTimer = get_tree().create_timer(0)


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
