class_name UnitStateLoss
extends State

func start() -> void:
	var unit: Unit = behavior.unit
	unit.animation.play("die")
	await unit.animation.animation_finished
	unit.died.emit()
	await unit.get_tree().create_timer(2).timeout
	behavior.unit.queue_free()
