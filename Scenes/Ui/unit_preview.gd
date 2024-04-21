extends PanelContainer

@onready var unit = $SubViewportContainer/SubViewport/FireUnit
@onready var viewport = $SubViewportContainer/SubViewport
@onready var xbox_pic = $HBoxContainer/XboxStickTexture
@onready var keyboard_pic = $HBoxContainer/keyboardTexture

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
	pass
