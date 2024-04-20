extends PanelContainer

@onready var unit = $SubViewportContainer/SubViewport/FireUnit
@onready var viewport = $SubViewportContainer/SubViewport

func set_unit(new_unit):
	unit.queue_free()
	viewport.add_child(new_unit)
	unit = new_unit
