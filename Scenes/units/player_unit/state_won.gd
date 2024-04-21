class_name UnitStateWon
extends State

func start() -> void:
	var unit: Unit = behavior.unit
	unit.animation.play("disapear")
	await unit.animation.animation_finished
	unit.disapeared.emit()
	await unit.get_tree().create_timer(2).timeout
	behavior.unit.queue_free()
	
