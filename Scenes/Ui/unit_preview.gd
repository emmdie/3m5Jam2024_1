extends PanelContainer

@onready var unit = $SubViewportContainer/SubViewport/FireUnit
@onready var viewport = $SubViewportContainer/SubViewport

func set_unit(new_unit):
	clear()
	viewport.add_child(new_unit)
	unit = new_unit

func clear():
	if unit != null:
		unit.queue_free()
		unit = null
