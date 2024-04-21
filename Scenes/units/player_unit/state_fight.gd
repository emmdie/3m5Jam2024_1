class_name UnitStateFight
extends State

func start() -> void:
	var unit: Unit = behavior.unit
	unit.animation.play("attack")
	await unit.animation.animation_finished
	
	if unit.has_won:
		behavior.change_state(UnitStateWon.new())
	else:
		behavior.change_state(UnitStateLoss.new())

	unit.fight_finished.emit()
