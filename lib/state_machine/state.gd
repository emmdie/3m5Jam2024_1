class_name State
extends RefCounted

var behavior: Behavior


func start() -> void:
	pass

func run(_delta: float) -> void:
	pass

func end(new_state: State) -> void:
	new_state.behavior = behavior
	behavior.current_state = new_state
	new_state.start()
