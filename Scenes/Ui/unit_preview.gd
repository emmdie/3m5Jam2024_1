extends PanelContainer

@onready var unit = $SubViewportContainer/SubViewport/FireUnit
@onready var viewport = $SubViewportContainer/SubViewport
@onready var xbox_pic = $HBoxContainer/XboxStickTexture
@onready var keyboard_pic = $HBoxContainer/keyboardTexture
@onready var circle = $CircleTexture

func _ready() -> void:
	GameState.input_mode.changed.connect(_on_input_mode_changed)
func set_unit(new_unit):
	clear()
	viewport.add_child(new_unit)
	unit = new_unit

func clear():
	if unit != null:
		unit.queue_free()
		unit = null

func set_icons(icons: Array[Texture]):
	keyboard_pic.texture = icons[0]
	xbox_pic.texture = icons[1]

func highlight(value: bool):
	circle.visible = value

func _on_input_mode_changed():
	if GameState.input_mode.value == 0:
		xbox_pic.visible = true
		keyboard_pic.visible = false
	if GameState.input_mode.value == 1:
		xbox_pic.visible = false
		keyboard_pic.visible = true
