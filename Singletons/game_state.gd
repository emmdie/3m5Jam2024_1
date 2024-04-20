@tool
extends GameStateBase

# Some example variable.
var highscore := Value.new(0)


var rules := GameRules.new()

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
