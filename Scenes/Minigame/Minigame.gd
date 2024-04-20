extends Control

@onready var input_sequence = load("res://Scenes/Minigame/input_sequence.tscn")
@onready var ManaBar = $VBoxContainer/ManaContainer/ManaBar
@onready var ManaValue = $VBoxContainer/ManaContainer/ManaValue

var max_displayed_input_sequences = 7
var pressed_key_mapping = {"minigame_Left":"l", "minigame_Right":"r", "minigame_Up":"u", "minigame_Down":"d"}
var sequences = []
var current_sequence_position
var mana = 0
var max_mana = 20 
var mana_gain = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	ManaBar.value = mana
	ManaBar.max_value = max_mana
	ManaValue.text = str(mana)

	for n in max_displayed_input_sequences:
		var new_sequence = _add_input_prompt()
		sequences.append(new_sequence)
	current_sequence_position = 0

func _process(delta):
	if Input.is_action_pressed("minigame_Left"):
		_check_input("minigame_Left")
	if Input.is_action_pressed("minigame_Right"):
		_check_input("minigame_Right")
	if Input.is_action_pressed("minigame_Down"):
		_check_input("minigame_Down")
	if Input.is_action_pressed("minigame_Up"):
		_check_input("minigame_Up")

func _check_input(event):
	print(event)
	if sequences[current_sequence_position]._check_input(pressed_key_mapping[event]):
		_set_mana(mana + mana_gain)
		sequences[current_sequence_position].queue_free()
		sequences[current_sequence_position] = _add_input_prompt()
		if current_sequence_position >= max_displayed_input_sequences:
			current_sequence_position = 0
		else:
			current_sequence_position = current_sequence_position + 1

func _set_mana(new_value):
	if new_value <= max_mana:
		mana = new_value
		ManaBar.value = new_value
		ManaValue.text = str(new_value)

func _add_input_prompt():
	var new_input = input_sequence.instantiate()
	$VBoxContainer/InputList.add_child(new_input)
	return new_input
