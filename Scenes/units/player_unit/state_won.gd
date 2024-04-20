class_name UnitStateWon
extends State

func start() -> void:
	behavior.unit.queue_free()
