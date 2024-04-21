@tool
extends Node3D
class_name Lane

const forward := Vector3.FORWARD
@export var progress: float = 0.0
@export var lange_length: float = 4.0:
	set(val):
		lange_length = val

var joypad: Node3D
var keyboard: Node3D

func _ready():
	joypad = get_node_or_null("JoypadControl")
	keyboard = get_node_or_null("KeyboardControl")
	lange_length = lange_length
	GameState.input_mode.changed.connect(__update_inputs)

func __update_inputs():
	print(joypad)
	if joypad:
		joypad.visible = GameState.input_mode.value == 0
	if keyboard:
		keyboard.visible = GameState.input_mode.value == 1
