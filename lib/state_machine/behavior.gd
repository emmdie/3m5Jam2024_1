class_name Behavior
extends Node


@export var unit: BaseUnit
@export var start_state: GDScript

var stopped: bool = false

var current_state: State = State.new()


func _ready() -> void:
	current_state.behavior = self
	change_state(start_state.new())


func _process(delta: float) -> void:
	if stopped:
		return
	current_state.run(delta)


func change_state(new_state: State) -> void:
	if stopped:
		return
	current_state.end(new_state)
